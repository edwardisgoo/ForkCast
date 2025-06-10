import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated loading indicator that spells "ForkCast" with
/// bouncing letters. Each letter takes about one second to
/// complete a bounce and letters animate sequentially.
class ForkCastLoading extends StatefulWidget {
  const ForkCastLoading({super.key});

  @override
  State<ForkCastLoading> createState() => _ForkCastLoadingState();
}

class _ForkCastLoadingState extends State<ForkCastLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const List<String> _letters = ['F', 'o', 'r', 'k', 'C', 'a', 's', 't'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double bounceHeight = 8.0;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value * _letters.length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letters.length, (index) {
            double t = progress - index;
            if (t < 0) t += _letters.length;
            double dy = 0;
            if (t >= 0 && t < 1) {
              dy = -math.sin(t * math.pi) * bounceHeight;
            }
            return Transform.translate(
              offset: Offset(0, dy),
              child: Text(
                _letters[index],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
