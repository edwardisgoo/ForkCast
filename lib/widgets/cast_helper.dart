import 'package:flutter/material.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';
import 'package:flutter_app/services/location_service.dart';

/// Global storage for the latest cast results.
List<RestaurantOutput> castResults = [];

/// Performs a restaurant cast using the current user location.
/// Displays a simple progress dialog while waiting for the
/// recommendation service and stores the returned results in
/// [castResults].
Future<void> performCast(BuildContext context) async {
  // show modal progress indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // acquire location
    final pos = await LocationService().getCurrentLocation();

    // use current time and simple defaults for now
    final now = DateTime.now();
    final queryTime = HourMin.fromInts(now.hour, now.minute);
    const query = Query(
      minPrice: 0,
      maxPrice: 500,
      minDistance: 0,
      maxDistance: 3000,
      requirement: '',
      note: '',
    );
    const setting = UserSetting(sortedPreference: ['價格', '距離', '評價', '人潮']);

    final result = await fetchRestaurant(
      queryTime,
      pos.latitude,
      pos.longitude,
      query,
      setting,
    );

    castResults = List<RestaurantOutput>.from(result['result'] ?? []);
  } catch (e) {
    debugPrint('performCast error: $e');
  } finally {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
