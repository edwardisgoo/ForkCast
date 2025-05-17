import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/models/restaurant_input.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/query.dart';

/*
光齊：主要排序餐廳的Flow
Input:
List<RestaurantInput> dataRestaurants:
由GoogleMap API得到的可能餐廳清單
Query:extraPreference
調整需求頁面的所有資訊
UserSetting:
用於讀取喜好排序

Ouput:{'result':List<RestaurantOutput>}經由Flow流程得出的
*/
Future<Map<String, dynamic>> fetchRestaurant(
  List<RestaurantRaw> rawdataRestaurants,
  HourMin queryTime,
  double queryLat,
  double queryLng,
  Query extraPreference,
  UserSetting userSetting,
) async {
  List<RestaurantInput> dataRestaurants = [];
  for (var rawRestaurant in rawdataRestaurants) {
    dataRestaurants.add(
        RestaurantInput.fromRaw(rawRestaurant, queryTime, queryLat, queryLng));
  }
  try {
    //還沒實作
    final HttpsCallable callableFindRestaurants =
        FirebaseFunctions.instance.httpsCallable(
      'findRestaurants',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 30), // 增加Timeout
      ),
    );
    final HttpsCallable callableDetailGeneration =
        FirebaseFunctions.instance.httpsCallable(
      'detailGeneration',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 30), // 增加Timeout
      ),
    );
    final List<Map<String, dynamic>> serializedRestaurants =
        dataRestaurants.map((restaurant) => restaurant.toJson()).toList();
    for (var restaurant in serializedRestaurants) {
      if (restaurant == null) {
        throw Exception("Restaurant data cannot be null");
      }
    }
    final Map<String, dynamic> requestData = {
      "restaurants": serializedRestaurants,
      "query": {
        "minPrice": extraPreference.minPrice,
        "maxPrice": extraPreference.maxPrice,
        "minDistance": extraPreference.minDistance,
        "maxDistance": extraPreference.maxDistance,
        "requirement": extraPreference.requirement,
        "note": extraPreference.note,
      },
      "userSetting": {
        "sortedPreference": userSetting.sortedPreference,
      },
    };
    print('Request data of findRestaurants: $requestData');
    final responseFindRestaurants =
        await callableFindRestaurants.call(requestData);
    print(
        'Firebase response of findRestaurants: ${responseFindRestaurants.data}');

    if (responseFindRestaurants.data == null) {
      print("Error: Response data is null");
      throw Exception("Response data is null");
    }
    final rawData = responseFindRestaurants.data as Map<String, dynamic>;
    if (rawData is! Map) {
      throw Exception("Invalid response format from Firebase");
    }
    final data = <String, dynamic>{};
    try {
      rawData.forEach((key, value) {
        data[key.toString()] = value;
      });
    } catch (e) {
      throw Exception(
          "Error happens in converting data to type Map<String, dynamic> $e");
    }
    if (!data.containsKey("topIndexes")) {
      print("Error: 'topIndexes' key not found in response");
      throw Exception("'topIndexes' key not found in response");
    }
    if (!data.containsKey("recommendations")) {
      print("Error: 'recommendations' key not found in response");
      throw Exception("'recommendations' key not found in response");
    }
    List<RestaurantOutput> result = [];
    final List<int> topIndexes = data["topIndexes"].whereType<int>().toList();
    final List<Map<String, dynamic>> recommendations =
        (data["recommendations"] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    for (int i = 0; i < topIndexes.length; i++) {
      final int index = topIndexes[i];
      final Map<String, dynamic>? recommendation =
          recommendations.firstWhere((r) => r["index"] == index);

      if (recommendation != null && index < dataRestaurants.length) {
        final Map<String, dynamic> requestData = {
          "restaurant": serializedRestaurants[index],
          "query": {
            "minPrice": extraPreference.minPrice,
            "maxPrice": extraPreference.maxPrice,
            "minDistance": extraPreference.minDistance,
            "maxDistance": extraPreference.maxDistance,
            "requirement": extraPreference.requirement,
            "note": extraPreference.note,
          },
          "userSetting": {
            "sortedPreference": userSetting.sortedPreference,
          },
          "previousRecommendation": recommendation
        };
        print('Request data of detailGeneration: $requestData');
        final response;
        try {
          response = await callableDetailGeneration.call(requestData);
          print(
              'After calling detailGeneration, response.data ${response.data}');
        } catch (err) {
          throw Exception("Error happens in calling detailGeneration:${err}");
        }
        result.add(RestaurantOutput(
          raw: rawdataRestaurants[index],
          reason: recommendation["reason"] ?? "",
          matchScore: recommendation["matchScore"].toDouble() ?? 0.0,
          priceScore: recommendation["matchDetail"]["price"].toDouble() ?? 0.0,
          distanceScore:
              recommendation["matchDetail"]["distance"].toDouble() ?? 0.0,
          ratingScore:
              recommendation["matchDetail"]["rating"].toDouble() ?? 0.0,
          preferenceScore:
              recommendation["matchDetail"]["preference"].toDouble() ?? 0.0,
          requirementScore:
              recommendation["matchDetail"]["requirement"].toDouble() ?? 0.0,
        ));
      }
    }
    if (recommendations.length != result.length)
      print("Didn't match all indexes");
    return {'result': result};
  } catch (e) {
    print(
        "Error calling fetchRestaurants in services/fetchRestaurants.dart: $e");
    throw Exception("Failed to fetch custom recipe $e");
  }
}
