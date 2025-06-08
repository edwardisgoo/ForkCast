import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/models/userSetting.dart';

class SearchResult {
  final List<RestaurantOutput> restaurants;
  final Query queryParameters;
  final UserSetting userPreferences;
  final DateTime timestamp;

  SearchResult({
    required this.restaurants,
    required this.queryParameters,
    required this.userPreferences,
    required this.timestamp,
  });

  // Optional: Add fromJson/toJson if needed for serialization,
  // but keeping it simple as per the current request.

  // Optional: Add a copyWith method if you need to create modified copies
  SearchResult copyWith({
    List<RestaurantOutput>? restaurants,
    Query? queryParameters,
    UserSetting? userPreferences,
    DateTime? timestamp,
  }) {
    return SearchResult(
      restaurants: restaurants ?? this.restaurants,
      queryParameters: queryParameters ?? this.queryParameters,
      userPreferences: userPreferences ?? this.userPreferences,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
