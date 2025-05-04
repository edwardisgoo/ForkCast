import 'package:cloud_functions/cloud_functions.dart';
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
  List<RestaurantInput> dataRestaurants,
  Query extraPreference,
  UserSetting userSetting,
) async {
  try {
    //還沒實作
    /*final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      //'customRecipeExample',
      'customRecipe', //'customRecipeExample',
    );
    print('Calling customRecipe function on firebase');
    //final response = await callable.call(ingredients);
    final response = await callable.call({
      "suggestRecipe": {
        "title": recipeTitle,
        "ingredients": recipeIngredients,
        "directions": recipeDirections,
      },
      "ingredients": ingredients,
    });
    //print('Firebase response: ${response.data}'); // <-- 新增這行，觀察 Firebase 回傳的結果
    if (response.data == null) {
      print("Error: Response data is null");
      throw Exception("Response data is null");
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    //print('Parsed data: $data'); // <-- 新增這行，確保 data 不是 null
    if (!data.containsKey("recipe")) {
      print("Error: 'recipe' key not found in response");
      throw Exception("'recipe' key not found in response");
    }
    if (!data.containsKey("customRecipeImage")) {
      print("Error: 'customRecipeImage' key not found in response");
      throw Exception("'customRecipeImage' key not found in response");
    }
    if (!data.containsKey("originRecipeImage")) {
      print("Error: 'originRecipeImage' key not found in response");
      throw Exception("'originRecipeImage' key not found in response");
    }
    final customRecipe = Map<String, dynamic>.from(data["recipe"]);
    final customRecipeImage = Map<String, dynamic>.from(
      data["customRecipeImage"],
    );
    final originRecipeImage = Map<String, dynamic>.from(
      data["originRecipeImage"],
    );
    /*if (!originRecipeImage.containsKey("url")) {
      print("Error: 'url' key not found in originRecipeImage");
      throw Exception("'url' key not found in originRecipeImage");
    }*/
    //print("originRecipeImage['url']=: ${originRecipeImage["url"]}");
  */
    List<RestaurantOutput> result = [];
    return {
      'result': result
    };
  } catch (e) {
    print("Error calling custom recipe: $e");
    throw Exception("Failed to fetch custom recipe");
  }
}
