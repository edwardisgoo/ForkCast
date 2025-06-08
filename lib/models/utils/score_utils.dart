import 'package:flutter_app/models/restaurant_output.dart';

/// Helper methods for working with restaurant match scores.
class ScoreUtils {
  /// Built in preference tags that are not user defined.
  static const List<String> builtIns = ['價格', '距離', '評價'];

  /// Convert a 0-1 score to a 1-5 rating (rounded).
  static int scaleToFive(double score) => (1 + score * 4).round();

  /// Returns the top two scoring categories for the given restaurant.
  /// Requirement score is ignored when ranking.
  /// The map keys are human readable labels.
  static List<MapEntry<String, double>> topTwo(
    RestaurantOutput r, [
    List<String>? sortedPrefs,
  ]) {
    final hasUserTags = sortedPrefs?.any((p) => !builtIns.contains(p)) ?? false;
    final entries = <MapEntry<String, double>>[
      MapEntry('價格', r.priceScore),
      MapEntry('距離', r.distanceScore),
      MapEntry('評價', r.ratingScore),
    ];
    if (hasUserTags) {
      entries.add(MapEntry('偏好', r.preferenceScore));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(2).toList();
  }

  /// Returns the first user preference tag that has an explanation.
  static String bestPreferenceTag(
      RestaurantOutput r, List<String> sortedPrefs) {
    for (final pref in sortedPrefs) {
      if (!builtIns.contains(pref) && r.reasons.containsKey(pref)) {
        return pref;
      }
    }
    for (final pref in sortedPrefs) {
      if (r.reasons.containsKey(pref)) return pref;
    }
    return '';
  }
}
