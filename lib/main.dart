// lib/main.dart
//
// Original style/theme kept exactly the same.
// Only change → wrap `NavigationService` and the new `RatingProvider`
// in a `MultiProvider` so the rating-prompt logic can work.

import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/firebase_options.dart';

import 'package:flutter_app/providers/rating_provider.dart';
import 'package:flutter_app/services/location_service.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase for the main application
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Failed to initialize Firebase in main.dart: $e');
    // Handle Firebase initialization error, e.g., show an error screen
    // For now, we'll let it proceed, but in a production app, you might stop.
    if (!e.toString().contains('duplicate-app')) {
        // Potentially rethrow or handle critical failure
    }
  }

  runApp(
    MultiProvider(
      providers: [
        // Pass the routerConfig (GoRouter instance) to NavigationService
        Provider<NavigationService>(create: (_) => NavigationService(routerConfig)),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        Provider<LocationService>(create: (_) => LocationService()),
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
      routerConfig: routerConfig, // Use the routerConfig from navigation.dart
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
    );
  }
}