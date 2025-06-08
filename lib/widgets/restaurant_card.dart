// lib/widgets/restaurant_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/providers/rating_provider.dart'; // ← NEW
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/utils/score_utils.dart';

/// Structured and responsive restaurant card.
class RestaurantCard extends StatelessWidget {
  final int index;
  final RestaurantOutput restaurant;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final double opacity;

  const RestaurantCard({
    super.key,
    required this.index,
    required this.restaurant,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);

    // Base sizes that stay constant
    final double baseCardH =
        (MediaQuery.of(context).size.height * 0.25).clamp(180.0, 320.0);
    final double imgH = baseCardH * 0.70;
    final double ratingSize = baseCardH * 0.30;
    final double titleFont = baseCardH * 0.09;
    final double digitFont = baseCardH * 0.32;
    final double dotFont = baseCardH * 0.16;

    // Price ratings based on index
    final topScores = ScoreUtils.topTwo(restaurant);
    final String p1Label = topScores[0].key;
    final String p1Score =
        ScoreUtils.scaleToFive(topScores[0].value).toString();
    final String p2Label = topScores[1].key;
    final String p2Score =
        ScoreUtils.scaleToFive(topScores[1].value).toString();

    final String name =
        restaurant.input.name.isNotEmpty ? restaurant.input.name : '未知餐廳';
    final double overall = 1 + restaurant.matchScore * 4;
    final String ratingStr = overall.toStringAsFixed(1);
    final List<String> ratingParts = ratingStr.split('.');
    final String ratingInt = ratingParts.first;
    final String ratingDec = '.${ratingParts.last}';
    String description = restaurant.reason.isNotEmpty
        ? restaurant.reason
        : restaurant.shortIntroduction;
    if (description.isEmpty) description = restaurant.input.summary;

    return Opacity(
      opacity: opacity,
      child: Dismissible(
        key: ValueKey(index),

        // ──────────────────────────────────────────────
        // use confirmDismiss so the parent fades / removes
        // the card; Dismissible itself never pops it out.
        // ──────────────────────────────────────────────
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // swipe right → maps
            context.read<RatingProvider>().setPending(restaurant.input.name);
            nav.goMaps();
          } else if (direction == DismissDirection.endToStart) {
            // swipe left → delete (fade-out handled by parent)
            onDelete();
          }
          // keep widget in the tree so fade-out can run
          return false;
        },

        // Right swipe (green, map)
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.map, color: Colors.white),
        ),
        // Left swipe (red, delete)
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),

        child: GestureDetector(
          onTap: isExpanded ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* ── top row ───────────────────────────────────── */
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* image */
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

                      /* right column */
                      Expanded(
                        child: SizedBox(
                          height: imgH,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: titleFont,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),

                              /* ratings row */
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  /* P1 */
                                  Column(
                                    children: [
                                      _ratingCircle(p1Score, ratingSize),
                                      const SizedBox(height: 4),
                                      Text(p1Label,
                                          style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),

                                  /* P2 */
                                  Column(
                                    children: [
                                      _ratingCircle(p2Score, ratingSize),
                                      const SizedBox(height: 4),
                                      Text(p2Label,
                                          style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(width: 16),

                                  /* overall */
                                  Column(
                                    children: [
                                      Container(
                                        height:
                                            math.max(digitFont + 8, ratingSize),
                                        alignment: Alignment.bottomLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              ratingInt,
                                              style: TextStyle(
                                                fontSize: digitFont,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(ratingDec,
                                                style: TextStyle(
                                                    fontSize: dotFont)),
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
                  const Spacer(),

                  /* bottom text */
                  Text(
                    description.isNotEmpty ? description : '無餐廳簡介',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
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
