import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class ComplexCastPage extends StatelessWidget {
  const ComplexCastPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Complex Cast Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => nav.goResult(),
          child: const Text('Go to Result'),
        ),
      ),
    );
  }
}
