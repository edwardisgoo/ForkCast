import 'package:flutter_app/models/restaurant_output.dart';

/// Helper methods for working with restaurant match scores.
class ScoreUtils {
  /// Convert a 0-1 score to a 1-5 rating (rounded).
  static int scaleToFive(double score) => (1 + score * 4).round();

  /// Returns the top two scoring categories for the given restaurant.
  /// The map keys are human readable labels.
  static List<MapEntry<String, double>> topTwo(RestaurantOutput r) {
    final entries = <MapEntry<String, double>>[
      MapEntry('價格', r.priceScore),
      MapEntry('距離', r.distanceScore),
      MapEntry('評價', r.ratingScore),
      MapEntry('偏好', r.preferenceScore),
      MapEntry('特殊需求', r.requirementScore),
    ];
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(2).toList();
  }
}
