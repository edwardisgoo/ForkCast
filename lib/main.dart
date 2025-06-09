// lib/main.dart
//
// Original style/theme kept exactly the same.
// Only change → wrap `NavigationService` and the new `RatingProvider`
// in a `MultiProvider` so the rating-prompt logic can work.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/rating_provider.dart'; // ★ new
import 'providers/permanent_blacklist.dart';
import 'providers/selected_restaurant_provider.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/services/location_service.dart'; // Import your location service

final theme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.blueGrey,
    onSecondary: Colors.white,
    surface: Color(0xFFE0E0E0),
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Courier'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ★ ensure binding

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Instantiate providers so we can perform initialization logic before
  // running the app.
  final navigationService = NavigationService();
  final ratingProvider = RatingProvider();
  final selectedRestaurantProvider = SelectedRestaurantProvider();
  final userSetting = UserSetting(sortedPreference: const ['價格', '距離', '評價']);
  final locationService = LocationService();
  final permanentBlacklist = PermanentBlacklist();
  await permanentBlacklist.initialized;
  final unwantedList = UnwantedList(unwantedIds: []);
  // Copy the persistent blacklist into the temporary unwanted list.
  unwantedList.replaceAll(permanentBlacklist.ids);
  final fetchedResults = FetchedResults();

  runApp(
    MultiProvider(
      providers: [
        Provider<NavigationService>.value(value: navigationService),
        ChangeNotifierProvider.value(value: ratingProvider), // ★
        ChangeNotifierProvider.value(value: selectedRestaurantProvider),
        ChangeNotifierProvider.value(value: userSetting),
        ChangeNotifierProvider.value(value: locationService),
        ChangeNotifierProvider.value(value: unwantedList),
        ChangeNotifierProvider.value(value: permanentBlacklist),
        ChangeNotifierProvider.value(value: fetchedResults),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: theme,
      routerConfig: routerConfig,
      restorationScopeId: 'app',
    );
  }
}
