import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/location_viewmodel.dart'; // Updated path

// Main function for standalone testing of LocationScreen
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider(
          create: (context) => LocationViewModel(
            locationService: Provider.of<LocationService>(context, listen: false),
          ),
        ),
      ],
      child: const TestLocationApp(),
    )
  );
}

// Specific MyApp for testing LocationScreen
class TestLocationApp extends StatelessWidget {
  const TestLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Test App (Standalone)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationScreen(),
    );
  }
}

// LocationScreen is now a StatelessWidget and consumes LocationViewModel
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('位置測試'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                viewModel.locationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => context.read<LocationViewModel>().fetchLocation(),
                child: viewModel.isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('獲取中...'),
                        ],
                      )
                    : const Text('獲取我的位置'),
              ),
              if (viewModel.latitude != null && viewModel.longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    '您的位置：(${viewModel.latitude}, ${viewModel.longitude})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}