import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => nav.goPreference(),
              child: const Text('Go to Preference'),
            ),
            const SizedBox(height: 16),
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
