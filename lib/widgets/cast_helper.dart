import 'package:flutter/material.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';
import 'package:flutter_app/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:geolocator/geolocator.dart';

/// Performs a restaurant cast using the current user location.
/// Displays a simple progress dialog while waiting for the
/// recommendation service and stores the returned results in
/// the [FetchedResults] provider.
Future<void> performCast(BuildContext context) async {
  // show modal progress indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    LocationService locationService = LocationService();
    Position userLocation = await locationService.getCurrentLocation();

    // Step 2: Fetch unwanted list from user settings using Provider
    UserSetting userSettings = Provider.of<UserSetting>(context, listen: false);
    UnwantedList unwantedList =
        Provider.of<UnwantedList>(context, listen: false);
    FetchedResults fetchedResults =
        Provider.of<FetchedResults>(context, listen: false);

    // Step 3: Call fetchRestaurant function to get restaurant recommendations
    Map<String, dynamic> restaurantResult = await fetchRestaurant(
      userSettings.queryTime,
      userLocation.latitude,
      userLocation.longitude,
      userSettings.query,
      unwantedList,
      userSettings,
    );

    // Step 4: Store fetched results using another Provider (FetchedResults)
    fetchedResults.setFetchedResults(
      restaurantResult['result'],
    );
  } catch (e) {
    debugPrint('performCast error: $e');
  } finally {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
