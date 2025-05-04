import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
          // Circular gear button at top right for navigating to PreferencePage
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(Icons.settings, color: Colors.black),
            ),
            onPressed: () => nav.goPreference(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => nav.goSimpleCast(),
              child: const Text('Go to Simple Cast'),
            ),
          ],
        ),
      ),
    );
  }
}
