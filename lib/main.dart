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
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/rating_provider.dart'; // ★ new
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/services/location_service.dart'; // Import your location service
import 'package:flutter_app/services/fetch_restaurant.dart'; //

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

  runApp(
    MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => RatingProvider()), // ★
        ChangeNotifierProvider(
          create: (_) =>
              UserSetting(sortedPreference: const ['價格', '距離', '評價']),
        ),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => UnwantedList(unwantedIds: [])),
        ChangeNotifierProvider(create: (_) => FetchedResults()),
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
