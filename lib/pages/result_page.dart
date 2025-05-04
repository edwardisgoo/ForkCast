import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int? expandedIndex;

  // When a small block is tapped, show its huge pop-up overlay.
  void _onSmallBlockTap(int index) {
    setState(() {
      expandedIndex = index;
    });
  }

  // When the huge block is tapped, navigate to maps_page.
  void _onExpandedBlockTap() {
    final nav = Provider.of<NavigationService>(context, listen: false);
    nav.goMaps();
  }

  // Dismiss the overlay (e.g., when tapping outside the huge block).
  void _dismissOverlay() {
    setState(() {
      expandedIndex = null;
    });
  }

  // Build one of the small blocks.
  Widget _buildSmallBlock(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onSmallBlockTap(index),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[(index + 1) * 200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Block ${index + 1}',
              style: const TextStyle(fontFamily: 'Courier', fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  // Build the huge pop-up overlay version of a block.
  Widget _buildExpandedOverlay(int index) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _dismissOverlay, // tap outside to dismiss
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: GestureDetector(
              onTap: _onExpandedBlockTap,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[(index + 1) * 200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Block ${index + 1}',
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 32),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        actions: [
          // Return button to go back to SimpleCastPage.
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => nav.goSimpleCast(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Three small blocks.
                      for (int i = 0; i < 3; i++) _buildSmallBlock(i),
                    ],
                  ),
                ),
              ),
              // Optional: "Cast again" button at the bottom (if desired).
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => nav.goResult(),
                  child: const Text('Cast again'),
                ),
              ),
            ],
          ),
          if (expandedIndex != null) _buildExpandedOverlay(expandedIndex!)
        ],
      ),
    );
  }
}
