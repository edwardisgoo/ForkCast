import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/restaurant_input.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/models/review.dart';

/*
Input:
HourMin queryTime
double queryLat,
double queryLng,
Query:extraPreference
調整需求頁面的所有資訊
UserSetting:
用於讀取喜好排序

Ouput:{'result':List<RestaurantOutput>}經由Flow流程得出的
*/
Future<Map<String, dynamic>> fetchRestaurant(
  HourMin queryTime,
  double queryLat,
  double queryLng,
  Query extraPreference,
  UnwantedList unwantedList,
  UserSetting userSetting,
) async {
  try {
    final HttpsCallable callableFindRestaurants =
        FirebaseFunctions.instance.httpsCallable(
      'restaurantRecommendationMock',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 40), // 增加Timeout
      ),
    );
    // 準備 Cloud Function 的輸入參數
    final Map<String, dynamic> functionInput = {
      'restaurantQuery': {
        'unwanted_restaurants': unwantedList.unwantedIds,
        'latitude': queryLat,
        'longitude': queryLng,
        'minPrice': extraPreference.minPrice,
        'maxPrice': extraPreference.maxPrice,
        'minDistance': extraPreference.minDistance * 1000,
        'maxDistance': extraPreference.maxDistance * 1000, //add
        'requirement': extraPreference.requirement,
        'note': extraPreference.note,
      },
      'userSetting': {
        'sortedPreference': userSetting.sortedPreference,
      },
      'queryTime': {
        'hour': queryTime.hour,
        'minute': queryTime.minute,
      },
    };

    print(functionInput);

    // 呼叫 Cloud Function
    final HttpsCallableResult functionResult =
        await callableFindRestaurants.call(functionInput);

    if (functionResult.data == null || functionResult.data.isEmpty) {
      print('Error: Cloud Function returned null or empty data.');
      throw Exception('Cloud Function returned no data.');
    }

    // 取得回傳結果
    final Map<String, dynamic> responseData =
        Map<String, dynamic>.from(functionResult.data);

    // 印出完整的 Flow response 進行 debug
    print('=== Cloud Function Response ===');
    print('Full response: ${functionResult.data}');
    print('Response type: ${functionResult.data.runtimeType}');
    print('================================');

    // 解析 topThreeRestaurants
    final List<dynamic> topThreeRestaurants =
        responseData['topThreeRestaurants'] ?? [];

    // 轉換成 RestaurantOutput 列表
    List<RestaurantOutput> result = [];

    for (var restaurantData in topThreeRestaurants) {
      try {
        // 印出每個餐廳的詳細資料結構
        print('--- Restaurant Data Structure ---');
        print('Restaurant data: $restaurantData');

        print('Restaurant data type: ${restaurantData.runtimeType}');

        // 解析 restaurant (RestaurantInput) - 正確處理類型轉換
        final Map<String, dynamic> restaurantMap =
            Map<String, dynamic>.from(restaurantData['restaurant']);
        print('Restaurant map: $restaurantMap');
        print('THIS IS ID: ${restaurantMap['id']}');

        // 解析 recommendation - 正確處理類型轉換
        final Map<String, dynamic> recommendationMap =
            Map<String, dynamic>.from(restaurantData['recommendation']);
        print('Recommendation map: $recommendationMap');
        print('\n\n\n\n\nIDDDDDDDDDD: ${restaurantMap['id']}');
        print('MatchDetail: ${recommendationMap['matchDetail']}');
        print(
            'MatchDetail type: ${recommendationMap['matchDetail'].runtimeType}');

        // 解析 details - 正確處理類型轉換
        final Map<String, dynamic> detailsMap =
            Map<String, dynamic>.from(restaurantData['details']);
        print('Details map: $detailsMap');
        print('-------------------------------');

        // 從 RestaurantInput 數據創建 RestaurantInput 物件
        final RestaurantInput restaurantInput =
            _parseRestaurantInput(restaurantMap);

        // 正確解析 matchDetail 物件
        final Map<String, dynamic> matchDetailMap =
            Map<String, dynamic>.from(recommendationMap['matchDetail'] ?? {});

        // 創建 RestaurantOutput，使用 RestaurantInput
        final RestaurantOutput restaurantOutput = RestaurantOutput(
          input: restaurantInput,
          reason: recommendationMap['reason'] ?? '',
          matchScore: (recommendationMap['matchScore'] ?? 0.0).toDouble(),
          priceScore: (matchDetailMap['price'] ?? 0.0).toDouble(),
          distanceScore: (matchDetailMap['distance'] ?? 0.0).toDouble(),
          ratingScore: (matchDetailMap['rating'] ?? 0.0).toDouble(),
          preferenceScore: (matchDetailMap['preference'] ?? 0.0).toDouble(),
          requirementScore: (matchDetailMap['requirement'] ?? 0.0).toDouble(),
        );

        // 添加詳細信息 - 處理嵌套的 preferenceAnalysis map
        final Map<String, String> reasonsMap = {};
        if (detailsMap['preferenceAnalysis'] != null) {
          final dynamic reasonsData = detailsMap['preferenceAnalysis'];
          if (reasonsData is Map) {
            reasonsData.forEach((key, value) {
              reasonsMap[key.toString()] = value.toString();
            });
          }
        }

        restaurantOutput.addDetails(
          short: detailsMap['shortIntroduction'] ?? '',
          full: detailsMap['fullIntroduction'] ?? '',
          menu: detailsMap['menu'] ?? '',
          reviews: detailsMap['reviews'] ?? '',
          reasons: reasonsMap,
        );

        result.add(restaurantOutput);
      } catch (parseError) {
        print('Error parsing restaurant data: $parseError');
        // 跳過這個餐廳，繼續處理下一個
        continue;
      }
    }

    return {'result': result};
  } catch (e) {
    print('Error in fetchRestaurant: $e');
    throw Exception(
        'Failed to fetch restaurant recommendations: ${e.toString()}');
  }
}

// 新增：解析 RestaurantInput 的函數
RestaurantInput _parseRestaurantInput(Map<String, dynamic> data) {
  // 解析 reviews
  List<Review> reviews = [];
  if (data['reviews'] != null && data['reviews'] is List) {
    for (var reviewData in data['reviews']) {
      if (reviewData is Map) {
        reviews.add(Review(
          rating: (reviewData['rating'] ?? 0.0).toDouble(),
          time: reviewData['time']?.toString() ?? '',
          text: reviewData['text']?.toString() ?? '',
        ));
      }
    }
  }
  // 解析 photoUrl
  List<String> photoUrls = [];
  // print('開始解析photoUrls');
  // print('準備開搞得阿${data}');
  // print('準備開搞得阿${data.keys}');
  // print('內容阿${data['photoURL']}');
  if (data['photoURL'] != null && data['photoURL'] is List) {
    for (var url in data['photoURL']) {
      if (url is String) {
        photoUrls.add(url);
      }
    }
  }
  // 解析 openingHours
  List<TimePeriod> openingHours = [];
  if (data['openingHours'] != null && data['openingHours'] is List) {
    for (var period in data['openingHours']) {
      if (period is Map) {
        try {
          if (period.containsKey('day') &&
              period.containsKey('start') &&
              period.containsKey('end')) {
            openingHours.add(TimePeriod.fromInts(
                period['start']['hour'],
                period['start']['minute'],
                period['end']['hour'],
                period['end']['minute'],
                period['day']));
          }
        } catch (e) {
          throw Exception('出事了阿伯: ${e.toString()}');
        }
      }
    }
  }
  print('我終於解析出日期$openingHours');

  return RestaurantInput(
    id: data['id'] ?? 'invalid',
    url: data['URL'] ?? '',
    address: data['address'] ?? '未抓取到地址',
    phoneNumber: data['phoneNumber'] ?? '未抓取到店家電話',
    openingHours: openingHours,
    photoUrl: photoUrls,
    distance: (data['distance'] ?? 0.0).toDouble(),
    opening: data['opening'] ?? false,
    rating: (data['rating'] ?? 0.0).toDouble(),
    reviews: reviews,
    photoImformation:
        data['photoInformation'] ?? data['photoImformation'] ?? '', // 處理可能的拼寫錯誤
    name: data['name'] ?? '',
    summary: data['summary'] ?? '',
    types: data['types'] ?? '',
    priceInformation: data['priceInformation'] ?? '',
    extraInformation: data['extraInformation'] ?? '',
  );
}
