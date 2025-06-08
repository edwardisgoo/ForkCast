import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_app/providers/restaurant_viewmodel.dart'; // Import ViewModel

// Main function for standalone testing of RestaurantTestPage
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Log error or handle as needed for testing
    print('Firebase initialization error in test main: $e');
    if (!e.toString().contains('duplicate-app')) {
      // rethrow; // Decide if rethrowing is needed for test environment
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => RestaurantViewModel(), // Provide ViewModel for standalone test
      child: const TestMyApp(), // Use a specific MyApp for testing
    ),
  );
}

// Specific MyApp for testing RestaurantTestPage
class TestMyApp extends StatelessWidget {
  const TestMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Fetch Test (Standalone)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RestaurantTestPage(), // RestaurantTestPage is now StatelessWidget
    );
  }
}

// RestaurantTestPage is now a StatelessWidget and consumes RestaurantViewModel
class RestaurantTestPage extends StatelessWidget {
  // Remove constructor if not needed, or add key if necessary:
  // const RestaurantTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the ViewModel
    final viewModel = context.watch<RestaurantViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Fetch Test')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('測試參數:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('位置: (${viewModel.queryLat}, ${viewModel.queryLng})', style: const TextStyle(fontSize: 18)),
                      Text('查詢時間: ${viewModel.queryTime.hour}:${viewModel.queryTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 18)),
                      Text('價格範圍: \$${viewModel.extraPreference.minPrice} - \$${viewModel.extraPreference.maxPrice}', style: const TextStyle(fontSize: 18)),
                      Text('距離範圍: ${viewModel.extraPreference.minDistance}m - ${viewModel.extraPreference.maxDistance}m', style: const TextStyle(fontSize: 18)),
                      Text('需求: ${viewModel.extraPreference.requirement}', style: const TextStyle(fontSize: 18)),
                      Text('備註: ${viewModel.extraPreference.note}', style: const TextStyle(fontSize: 18)),
                      Text('偏好排序: ${viewModel.userSetting.sortedPreference.join(' > ')}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => context.read<RestaurantViewModel>().fetchRestaurants(), // Call ViewModel method
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: viewModel.isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('測試中...'),
                          ],
                        )
                      : const Text('開始測試 fetchRestaurant'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('測試結果:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.resultText.isEmpty ? '點擊上方按鈕開始測試' : viewModel.resultText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// _RestaurantTestPageState is removed as its logic is now in RestaurantViewModel