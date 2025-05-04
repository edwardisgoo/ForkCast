import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Result Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => nav.goMaps(),
          child: const Text('Go to Maps'),
        ),
      ),
    );
  }
}
