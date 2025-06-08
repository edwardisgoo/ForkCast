import 'package:flutter/material.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:flutter_app/services/location_service.dart'; // Import your location service
import 'package:flutter_app/services/fetch_restaurant.dart'; // Import your fetch restaurant function
import 'package:flutter_app/models/userSetting.dart'; // Import y
// Import your fetch restaurant function

// Function to fetch restaurants based on user location and settings
void fetchAndStoreRestaurants(BuildContext context) async {
  try {
    // Step 1: Fetch user's current location using LocationService
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

    // Optional: Debug prints for verification
    print('Fetched and stored restaurant results successfully.');
  } catch (e) {
    print('Error fetching and storing restaurants: $e');
    // Handle errors as needed
  }
}
