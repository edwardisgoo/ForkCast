import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Structured and responsive restaurant card.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key});

  @override
  Widget build(BuildContext context) {
    // responsive sizes
    final double cardH =
        (MediaQuery.of(context).size.height * 0.25).clamp(180.0, 320.0);
    final double imgH = cardH * 0.70;
    final double ratingSize = cardH * 0.30;
    final double titleFont = cardH * 0.09;
    final double digitFont = cardH * 0.32; // ← main digit size
    final double dotFont = cardH * 0.16;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: cardH,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── top row ────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ▓ image ▓
                Container(
                  width: imgH,
                  height: imgH,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.image, size: 48)),
                ),
                const SizedBox(width: 12),

                // ── right column ──
                Expanded(
                  child: SizedBox(
                    height: imgH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title
                        Text(
                          '品田牧場日式豬排咖哩',
                          style: TextStyle(
                            fontSize: titleFont,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        const Spacer(),

                        // ratings row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // P1
                            Column(
                              children: [
                                _ratingCircle('4', ratingSize),
                                const SizedBox(height: 4),
                                const Text('價格',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(width: 8),

                            // P2
                            Column(
                              children: [
                                _ratingCircle('5', ratingSize),
                                const SizedBox(height: 4),
                                const Text('口味',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // overall rating
                            Column(
                              children: [
                                // enough height to avoid clipping but still bottom-aligned
                                Container(
                                  height: math.max(digitFont + 8, ratingSize),
                                  alignment: Alignment.bottomLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '3',
                                        style: TextStyle(
                                          fontSize: digitFont,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '.7',
                                        style: TextStyle(fontSize: dotFont),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('綜合評價',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── explanation line ──────────────────────────────
            const Spacer(),
            const Text(
              '如果你想吃咖哩，品田牧場提供多樣的日式咖哩料理',
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// circular rating indicator
  Widget _ratingCircle(String rating, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!),
        ),
        alignment: Alignment.center,
        child: Text(
          rating,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
}
