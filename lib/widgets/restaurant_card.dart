import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/providers/rating_provider.dart';
import 'package:flutter_app/models/utils/score_utils.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:transparent_image/transparent_image.dart';

/// Structured and responsive restaurant card.

class RestaurantCard extends StatelessWidget {
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final double opacity;

  const RestaurantCard({
    super.key,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.onDelete,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    final restaurant = context.watch<FetchedResults>().fetchedResults[index];
    final setting = context.read<UserSetting>();
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final double cardPadding =
        12.0; // This is internal padding for the card content
    final double availableWidth = screenWidth * 0.9 - (cardPadding * 2);
    final double baseCardH =
        (MediaQuery.of(context).size.height * 0.25).clamp(50.0, 320.0);
    final double textLine = baseCardH * 0.07; // one line of text height

    // Modified image dimensions: image height reduced by two text lines instead of one
    final double imgH = (baseCardH * 0.70) - (2 * textLine);
    final double imgW = imgH;
    final double ratingSize =
        baseCardH * 0.15; // reduced from 0.20 for a smaller ratings row
    final double titleFont = baseCardH * 0.07;
    final double digitFont = baseCardH * 0.28;
    final double dotFont = baseCardH * 0.08;

    // Dynamic font sizes for smaller labels
    final double smallLabelFont = (baseCardH * 0.06).clamp(10.0, 14.0);
    final double descriptionFont = (baseCardH * 0.065).clamp(11.0, 15.0);

    final topScores = ScoreUtils.topTwo(restaurant, setting.sortedPreference);
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

    String description = restaurant.shortIntroduction.isNotEmpty
        ? restaurant.shortIntroduction
        : '系統根據評分推薦的餐廳';

    if (description.isEmpty) description = restaurant.input.summary;

    return Opacity(
      opacity: opacity,
      child: Dismissible(
        key: ValueKey(index),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            context.read<RatingProvider>().setPending(restaurant.input.name);

            nav.goMaps();
          } else if (direction == DismissDirection.endToStart) {
            onDelete();
          }

          return false;
        },
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: screenWidth * 0.05),
          child: const Icon(Icons.map, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: screenWidth * 0.05),
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
            constraints: BoxConstraints(maxWidth: availableWidth),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* ── top row ───────────────────────────────────── */

                  Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* image */

                          Container(
                            width: imgW,
                            height: imgH,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: restaurant.input.photoUrl.length == 0
                                // false

                                ? Center(
                                    child: Icon(Icons.image, size: imgH * 0.5))
                                : FadeInImage(
                                    placeholder: MemoryImage(kTransparentImage),
                                    image: NetworkImage(
                                        restaurant.input.photoUrl[0]),
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: double.infinity,
                                  ), // Relative icon size
                          ),
                          // Use dynamic spacing for right column separation
                          SizedBox(width: availableWidth * 0.03),

                          /* right column */

                          Expanded(
                            child: SizedBox(
                              height: imgH,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: titleFont,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  SizedBox(
                                      height: baseCardH *
                                          0.02), // dynamic smaller spacing

                                  /* ratings row */
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      /* P1 */
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _ratingCircle(p1Score, ratingSize),
                                          SizedBox(
                                              height: baseCardH *
                                                  0.015), // reduced spacing
                                          Text(
                                            p1Label,
                                            style: TextStyle(
                                                fontSize: (baseCardH * 0.055)
                                                    .clamp(10.0, 14.0)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          width: availableWidth *
                                              0.02), // dynamic spacing
                                      /* P2 */
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _ratingCircle(p2Score, ratingSize),
                                          SizedBox(
                                              height: baseCardH *
                                                  0.015), // reduced spacing
                                          Text(
                                            p2Label,
                                            style: TextStyle(
                                                fontSize: (baseCardH * 0.055)
                                                    .clamp(10.0, 14.0)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          width: availableWidth *
                                              0.03), // dynamic spacing
                                      /* overall */
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  ratingInt,
                                                  style: TextStyle(
                                                    fontSize: (baseCardH * 0.25)
                                                        .clamp(20.0, 30.0),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  ratingDec,
                                                  style: TextStyle(
                                                      fontSize: (baseCardH *
                                                              0.10)
                                                          .clamp(10.0, 15.0)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: baseCardH * 0.02),
                                            Text(
                                              '綜合評價',
                                              style: TextStyle(
                                                  fontSize: (baseCardH * 0.055)
                                                      .clamp(10.0, 14.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      flex: 5),
                  SizedBox(
                      height: baseCardH * 0.02), // Reduced vertical spacing

                  /* bottom text */

                  Flexible(
                    child: Text(
                      description.isNotEmpty ? description : '無餐廳簡介',
                      style: TextStyle(fontSize: descriptionFont),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    flex: 2,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// circular rating indicator

  Widget _ratingCircle(String rating, double size) {
    Color _getColorFromRating(String score) {
    switch (rating) {
      case "5":
        return Colors.green;
      case "4":
        return Colors.lightGreen;
      case "3":
        return Colors.amber;
      case "2":
        return Colors.orange;
      case "1":
      default:
        return Colors.red;
    }
  }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorFromRating(rating),
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.grey[400]!,
            width: (size * 0.05).clamp(1.0, 2.5)), // Relative border width
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          rating,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
