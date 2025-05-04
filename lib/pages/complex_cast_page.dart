import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/navigation.dart';

class ComplexCastPage extends StatelessWidget {
  const ComplexCastPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Complex Cast Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Added text box for user input.
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type here',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => nav.goResult(),
              child: const Text('Go to Result Page'),
            ),
          ],
        ),
      ),
    );
  }
}
