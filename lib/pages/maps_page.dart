import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps Page')),
      body: Center(
        // Added button linking to external app/website (future integration)
        child: ElevatedButton(
          onPressed: () {
            // Future: link to Google Maps
          },
          child: const Text('Go to Google Maps'),
        ),
      ),
    );
  }
}
