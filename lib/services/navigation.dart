import 'package:flutter/material.dart';
import 'package:flutter_app/pages/main_page.dart';
import 'package:flutter_app/pages/preference_page.dart';
import 'package:flutter_app/pages/simple_cast_page.dart';
import 'package:flutter_app/pages/complex_cast_page.dart';
import 'package:flutter_app/pages/result_page.dart';
import 'package:flutter_app/pages/maps_page.dart';
import 'package:go_router/go_router.dart';

final routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/preference',
      builder: (context, state) => const PreferencePage(),
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
      builder: (context, state) => const ResultPage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'maps',
          builder: (context, state) => const MapsPage(),
        ),
      ],
    ),
  ],
  initialLocation: '/',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

class NavigationService {
  late final GoRouter _router;
  NavigationService() {
    _router = routerConfig;
  }

  void goMain() {
    _router.go('/');
  }

  void goPreference() {
    _router.go('/preference');
  }

  void goSimpleCast() {
    _router.go('/simple-cast');
  }

  void goComplexCast() {
    _router.go('/complex-cast');
  }

  void goResult() {
    _router.go('/result');
  }

  void goMaps() {
    _router.go('/result/maps');
  }
}
