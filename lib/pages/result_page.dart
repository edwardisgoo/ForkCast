import 'package:flutter/material.dart';
import '../services/navigation.dart';
import '../widgets/title_text.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/expanded_card.dart';
import '../widgets/cast_helper.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _titleKey = GlobalKey();
  bool _showCards = false;
  double _titleHeightPx = 30; // Initial estimate, will be measured
  // static const double _extraGapPx = 30; // Replaced by dynamic calculation
  int? _expandedCardIndex;
  Set<int> _deletedIndices = {};
  bool _isTransitioning = false;

  // Track which cards are fading out
  final Set<int> _fadingIndices = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTitle();
      final ctx = _titleKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        debugPrint(
            '[RESULT] title initial pos=${box.localToGlobal(Offset.zero)} size=${box.size}');
      }
      Future.delayed(const Duration(milliseconds: 300),
          () => setState(() => _showCards = true));
    });
  }

  void _measureTitle() {
    final ctx = _titleKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      setState(() => _titleHeightPx = box.size.height);
    }
  }

  void _handleDeletion(int index) {
    final results = context.read<FetchedResults>().fetchedResults;
    if (index >= 0 && index < results.length) {
      final id = results[index].input.id;
      context.read<UnwantedList>().addToUnwanted(id);
    }
    // First collapse if expanded
    if (_expandedCardIndex == index) {
      setState(() => _expandedCardIndex = null);
      // Wait for collapse animation before starting fade
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _fadingIndices.add(index));
          // Wait for fade out before removing
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _deletedIndices.add(index);
                _fadingIndices.remove(index);
              });
            }
          });
        }
      });
    } else {
      setState(() => _fadingIndices.add(index));
      // Wait for fade out before removing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _deletedIndices.add(index);
            _fadingIndices.remove(index);
          });
        }
      });
    }
  }

  void _handleExpand(int index) {
    setState(() {
      _isTransitioning = true;
      _expandedCardIndex = null;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _expandedCardIndex = index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final insets = MediaQuery.of(context).padding;
    final safeTop = insets.top;
    final safeBottom = insets.bottom;

    final double titleMainFontSize = (screenWidth * 0.075).clamp(26.0, 34.0);
    final double helperTextSize = (screenWidth * 0.025).clamp(12.0, 16.0);

    // Dynamic gap after title
    final double extraGapPx = (screenHeight * 0.03).clamp(20.0, 40.0);

    // Dynamic calculations for title and button vertical alignment
    final double topPaddingForTitle = (screenHeight * 0.02).clamp(12.0, 20.0);
    final titleY =
        2 * (safeTop + topPaddingForTitle + _titleHeightPx / 2) / screenHeight -
            1;

    final double buttonVerticalPadding =
        (screenHeight * 0.025).clamp(15.0, 25.0);
    final double buttonMinHeight =
        (screenHeight * 0.07).clamp(50.0, 70.0); // For text + padding
    final buttonY = 2 *
            (screenHeight -
                safeBottom -
                topPaddingForTitle -
                buttonMinHeight / 2) /
            screenHeight -
        1;

    final double listTop =
        safeTop + topPaddingForTitle + _titleHeightPx + extraGapPx;

    final double buttonPaddingHorizontal =
        (screenWidth * 0.15).clamp(50.0, 70.0);
    final double buttonFontSize = (screenWidth * 0.07).clamp(24.0, 32.0);
    final double estimatedButtonHeightWithPadding =
        buttonMinHeight + 2 * buttonVerticalPadding;
    final double btnPadPx = topPaddingForTitle +
        estimatedButtonHeightWithPadding; // Space for button area from bottom

    // Recalculate listBottom to push the button lower (thus giving more room
    // to the restaurant cards above). Previously:
    // final double listBottom = safeBottom + btnPadPx;
    final double listBottom = safeBottom +
        btnPadPx +
        (screenHeight * 0.05); // Increased bottom margin

    // Adjusted baselineShift for helper texts relative to title
    // This is an approximation. Fine-tuning might be needed based on specific font metrics.
    final double baselineShift = (_titleHeightPx * 0.1).clamp(5.0, 12.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => context.read<NavigationService>().goMain(),
              child: const CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, titleY),
            child: TitleText(key: _titleKey, fontSize: titleMainFontSize),
          ),
          Align(
            alignment:
                const Alignment(-0.8, 0), // Centered with title Y by default
            child: Transform.translate(
              offset: Offset(
                  0,
                  titleY * (screenHeight / 2) +
                      _titleHeightPx / 2 +
                      baselineShift), // Adjust to be below title
              child: Text(
                '左滑刪除餐廳',
                style: TextStyle(color: Colors.red, fontSize: helperTextSize),
              ),
            ),
          ),
          Align(
            alignment:
                const Alignment(0.8, 0), // Centered with title Y by default
            child: Transform.translate(
              offset: Offset(
                  0,
                  titleY * (screenHeight / 2) +
                      _titleHeightPx / 2 +
                      baselineShift), // Adjust to be below title
              child: Text(
                '右滑前往餐廳',
                style: TextStyle(color: Colors.green, fontSize: helperTextSize),
              ),
            ),
          ),
          Positioned(
            top: listTop,
            left: 0,
            right: 0,
            bottom: listBottom,
            child: AnimatedOpacity(
              opacity: _showCards ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: (screenWidth * 0.04)
                        .clamp(12.0, 20.0)), // Dynamic horizontal padding
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final restaurants =
                        context.watch<FetchedResults>().fetchedResults;

                    final double cardSpacing = (screenHeight * 0.015)
                        .clamp(8.0, 16.0); // Dynamic card spacing
                    // The '80' was likely for button area, now covered by listBottom calculation
                    final totalHeight =
                        constraints.maxHeight; // Use full available height

                    final cardHeight = restaurants.isEmpty ||
                            restaurants.length >
                                5 // Cap max cards visible without scrolling for very small heights
                        ? (totalHeight / 3.5 - cardSpacing).clamp(
                            (screenHeight * 0.25).clamp(180.0, 320.0),
                            280.0) // Fallback or max visible cards logic
                        : (totalHeight -
                                cardSpacing *
                                    (restaurants.length - 1)
                                        .clamp(0, double.infinity)) /
                            restaurants.length;

                    // Get indices of cards that haven't been deleted
                    final remainingIndices =
                        List.generate(restaurants.length, (i) => i)
                            .where((i) => !_deletedIndices.contains(i))
                            .toList();

                    return Stack(
                      children: remainingIndices.asMap().entries.map((entry) {
                        final visualIndex = entry.key; // Position in the stack
                        final actualIndex = entry.value; // Original card index
                        final bool isExpanded = _expandedCardIndex ==
                            actualIndex; // Defined locally
                        final double top =
                            visualIndex * (cardHeight + cardSpacing);

                        if (isExpanded) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            top: 0,
                            left: 0,
                            right: 0,
                            height: totalHeight,
                            onEnd: () =>
                                setState(() => _isTransitioning = false),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 1.0,
                              child: Center(
                                // <-- Wrap to center horizontally
                                child: ExpandedCard(
                                  index: actualIndex,
                                  onCollapse: () =>
                                      setState(() => _expandedCardIndex = null),
                                  opacity: 1.0,
                                  onDelete: () => _handleDeletion(actualIndex),
                                ),
                              ),
                            ),
                          );
                        }

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: top,
                          left: 0,
                          right: 0,
                          height: cardHeight,
                          child: IgnorePointer(
                            ignoring: _expandedCardIndex != null,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _expandedCardIndex == null &&
                                      !_isTransitioning &&
                                      !_fadingIndices.contains(actualIndex)
                                  ? 1.0
                                  : 0.0,
                              child: Center(
                                // <-- Wrap to center horizontally
                                child: RestaurantCard(
                                  index: actualIndex,
                                  isExpanded: false,
                                  onTap: () => _handleExpand(actualIndex),
                                  opacity: 1.0,
                                  onDelete: () => _handleDeletion(actualIndex),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          // Revert button alignment to use buttonY without extra offset.
          Align(
            alignment: Alignment(
                0, buttonY), // Removed added offset previously applied
            child: ElevatedButton(
              onPressed: () async {
                await performCast(context);
                if (!mounted) return;
                setState(() {
                  _deletedIndices = {};
                  _expandedCardIndex = null;
                  _isTransitioning = false;
                  _fadingIndices.clear();
                  _showCards = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                    horizontal: buttonPaddingHorizontal,
                    vertical: buttonVerticalPadding),
                textStyle: TextStyle(fontSize: buttonFontSize),
                minimumSize: Size(0, buttonMinHeight),
              ),
              child: const Text('Cast!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

