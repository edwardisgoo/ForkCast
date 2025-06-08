import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/services/main.dart' show RestaurantTestPage;
import 'package:flutter_app/services/lll.dart' show LocationScreen;
import 'package:flutter_app/pages/maps_page.dart';
import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/providers/restaurant_viewmodel.dart';
import 'package:flutter_app/providers/location_viewmodel.dart';
import 'package:flutter_app/services/location_service.dart';

import 'package:flutter_app/pages/simple_cast_page.dart';
import 'package:flutter_app/pages/complex_cast_page.dart';
import 'package:flutter_app/pages/result_page.dart'; // Uncommented and corrected
import 'package:flutter_app/pages/preference_page.dart'; // Added import

// Placeholder for your app's main page / home page
class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForkCast App Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ForkCast!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/restaurant-test'),
              child: const Text('Go to Restaurant Test Page'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/location-test'),
              child: const Text('Go to Location Test Page'),
            ),
            // Add navigation to other main features of your app here
          ],
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter routerConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AppHomePage(), // Main app home page
    ),
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'restaurantShell'),
      builder: (context, state, child) {
        // RestaurantViewModel does not have explicit dependencies from global providers here
        return ChangeNotifierProvider(
          create: (_) => RestaurantViewModel(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/restaurant-test',
          builder: (context, state) => RestaurantTestPage(),
        ),
      ],
    ),
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'locationShell'),
      builder: (context, state, child) {
        // LocationViewModel depends on LocationService (which is a global provider)
        return ChangeNotifierProvider(
          create: (ctx) => LocationViewModel(
            locationService: Provider.of<LocationService>(ctx, listen: false),
          ),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/location-test',
          builder: (context, state) => const LocationScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/maps',
      builder: (context, state) {
        final RestaurantRaw? restaurant = state.extra as RestaurantRaw?;
        return MapsPage(restaurant: restaurant);
      },
    ),
    GoRoute(
      path: '/simple-cast',
      builder: (context, state) => const SimpleCastPage(),
    ),
    GoRoute(
      path: '/complex-cast',
      builder: (context, state) => const ComplexCastPage(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        // The actual ResultPage doesn't take resultData in constructor.
        // If data is passed via `extra`, ResultPage needs to handle it internally.
        return const ResultPage();
      },
    ),
    GoRoute(
      path: '/preference', // Added route for PreferencePage
      builder: (context, state) => const PreferencePage(),
    ),
    // If MainPage is a distinct navigable route, add it here.
    // For example, if '/' is not your main_page.dart:
    // GoRoute(
    //   path: '/main', // Or whatever path your MainPage should have
    //   builder: (context, state) => const MainPage(), // Replace with your actual MainPage
    // ),
  ],
);

class NavigationService {
  final GoRouter router;

  NavigationService(this.router);

  void goMain() {
    router.go('/');
  }

  void goMaps({RestaurantRaw? restaurant}) {
    router.go('/maps', extra: restaurant);
  }

  void goToSimpleCast() {
    router.go('/simple-cast');
  }

  void goComplexCast() {
    router.go('/complex-cast');
  }

  void goBack() {
    if (router.canPop()) {
      router.pop();
    } else {
      print("NavigationService: Cannot pop from current route.");
    }
  }

  void goResult({dynamic data}) {
    router.go('/result', extra: data);
  }

  void goPreference() {
    router.go('/preference');
  }

  // If pages/main_page.dart is a specific target and not '/', add a dedicated method:
  // void goToMainPage() {
  //   router.go('/main'); // Assuming '/main' is the route for MainPage
  // }

  // Add other navigation methods as needed, using this.router
}
