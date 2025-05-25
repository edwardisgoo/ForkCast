import 'package:flutter/material.dart';
import '../widgets/title_text.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/expanded_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _titleKey = GlobalKey();
  bool _showCards = false;
  double _titleHeightPx = 30;
  static const double _extraGapPx = 30;
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
    final insets = MediaQuery.of(context).padding;
    final safeTop = insets.top;
    final safeBottom = insets.bottom;

    final double titleY = 2 * (safeTop + 16 + 15) / size.height - 1;
    final double buttonY =
        2 * (size.height - safeBottom - 16 - 30) / size.height - 1;
    final double listTop = safeTop + 16 + _titleHeightPx + _extraGapPx;
    const double btnPadPx = 16 + 60;
    final double listBottom = safeBottom + btnPadPx;
    const double baselineShift = (30 - 14) / 2;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, titleY),
            child: TitleText(key: _titleKey, fontSize: 30),
          ),
          Align(
            alignment: Alignment(-0.8, titleY),
            child: Transform.translate(
              offset: Offset(0, baselineShift),
              child: const Text(
                '左滑刪除餐廳',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0.8, titleY),
            child: Transform.translate(
              offset: Offset(0, baselineShift),
              child: const Text(
                '右滑前往餐廳',
                style: TextStyle(color: Colors.green, fontSize: 14),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalHeight = constraints.maxHeight - 80;
                    final cardHeight = (totalHeight - 24) / 3;

                    // Get indices of cards that haven't been deleted
                    final remainingIndices = List.generate(3, (i) => i)
                        .where((i) => !_deletedIndices.contains(i))
                        .toList();

                    return Stack(
                      children: remainingIndices.asMap().entries.map((entry) {
                        final visualIndex = entry.key; // Position in the stack
                        final actualIndex = entry.value; // Original card index
                        final top = visualIndex * (cardHeight + 12);
                        final isExpanded = _expandedCardIndex == actualIndex;

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
                              child: ExpandedCard(
                                index: actualIndex,
                                onCollapse: () =>
                                    setState(() => _expandedCardIndex = null),
                                opacity: 1.0,
                                onDelete: () => _handleDeletion(actualIndex),
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
                              child: RestaurantCard(
                                index: actualIndex,
                                isExpanded: false,
                                onTap: () => _handleExpand(actualIndex),
                                opacity: 1.0,
                                onDelete: () => _handleDeletion(actualIndex),
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
          Align(
            alignment: Alignment(0, buttonY),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showCards = false; // Start fade out
                });
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (mounted) {
                    setState(() {
                      _deletedIndices = {}; // Reset state
                      _expandedCardIndex = null;
                      _isTransitioning = false;
                      _fadingIndices.clear();
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        setState(() => _showCards = true); // Start fade in
                      }
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                textStyle: const TextStyle(fontSize: 28),
              ),
              child: const Text('Cast!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
