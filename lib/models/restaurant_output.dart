import 'package:flutter_app/models/restaurant_input.dart';

/*
光齊：針對呼叫fetchRestaurant時所需Output設計的Data Structure
*/
class RestaurantOutput {
  RestaurantOutput({
    required this.input,
    required this.reason,
    required this.matchScore,
    required this.priceScore,
    required this.distanceScore,
    required this.ratingScore,
    required this.preferenceScore,
    required this.requirementScore,
  });
  final RestaurantInput input;
  final String reason; // 簡短推薦原因
  final double matchScore;
  final double priceScore;
  final double distanceScore;
  final double ratingScore;
  final double preferenceScore;
  final double requirementScore;
  // 由detailGeneration後才會出現的資訊
  String shortIntroduction = "";
  String fullIntroduction = "";
  String menu = "";
  String reviews = "";
  Map<String, String> reasons = {};
  //加入details的function
  void addDetails({
    required String short,
    required String full,
    required String menu,
    required String reviews,
    required Map<String, String> reasons,
  }) {
    shortIntroduction = short;
    fullIntroduction = full;
    this.menu = menu;
    this.reviews = reviews;
    this.reasons = reasons;
  }
}
