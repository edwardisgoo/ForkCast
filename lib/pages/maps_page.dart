import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Maps Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => nav.goMain(),
          child: const Text('Back to Main'),
        ),
      ),
    );
  }
}
