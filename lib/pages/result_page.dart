import 'package:flutter/material.dart';
import '../widgets/title_text.dart';
import '../widgets/restaurant_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _titleKey = GlobalKey();
  bool _showCards = false;
  double _titleHeightPx = 30; // default bump to match new fontSize
  static const double _extraGapPx = 12; // space under title before cards

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTitle();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final insets = MediaQuery.of(context).padding;
    final safeTop = insets.top;
    final safeBottom = insets.bottom;

    // identical fractional Y math
    final double titleY =
        2 * (safeTop + 16 + 15) / size.height - 1; // 16px + half of 30px
    final double buttonY =
        2 * (size.height - safeBottom - 16 - 30) / size.height - 1;

    // scrolling list area
    final double listTop = safeTop + 16 + _titleHeightPx + _extraGapPx;
    const double btnPadPx = 16 + 60;
    final double listBottom = safeBottom + btnPadPx;

    // baseline shift to align font-size‐14 text under font‐size‐30 title
    const double baselineShift = (30 - 14) / 2;

    return Scaffold(
      body: Stack(
        children: [
          // Hero title
          Align(
            alignment: Alignment(0, titleY),
            child: Hero(
              tag: 'pageTitle',
              child: TitleText(key: _titleKey, fontSize: 30),
            ),
          ),

          // Left hint
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

          // Right hint
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

          // Restaurant cards
          Positioned(
            top: listTop,
            left: 0,
            right: 0,
            bottom: listBottom,
            child: AnimatedOpacity(
              opacity: _showCards ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: RestaurantCard(),
                ),
              ),
            ),
          ),

          // Cast! button
          Align(
            alignment: Alignment(0, buttonY),
            child: ElevatedButton(
              onPressed: () {},
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
