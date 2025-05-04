import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class SimpleCastPage extends StatelessWidget {
  const SimpleCastPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Cast Page')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => nav.goResult(),
              child: const Text('Go to Result'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => nav.goComplexCast(),
              child: const Text('Go to Complex Cast'),
            ),
          ],
        ),
      ),
    );
  }
}
