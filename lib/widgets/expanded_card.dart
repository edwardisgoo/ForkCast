import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/utils/score_utils.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/providers/rating_provider.dart';

class ExpandedCard extends StatefulWidget {
  final int index;
  final VoidCallback onCollapse;
  final VoidCallback onDelete;
  final double opacity;

  const ExpandedCard({
    super.key,
    required this.index,
    required this.onCollapse,
    required this.onDelete,
    required this.opacity,
  });

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
  bool _showContent = false;
  bool _isDismissed = false;
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300),
        () => mounted ? setState(() => _showContent = true) : null);
  }

  void _handleDismiss(DismissDirection dir) {
    if (_isDismissed) return;
    final nav = context.read<NavigationService>(); // Get NavigationService here
    final restaurant =
        context.read<FetchedResults>().fetchedResults[widget.index];
    setState(() {
      _isDismissed = true;
      _showContent = false;
    });

    if (dir == DismissDirection.startToEnd) {
      context
          .read<RatingProvider>()
          .setPending(id: restaurant.input.id, name: restaurant.input.name);
      nav.goMaps(); // Use the local variable
      widget.onCollapse();
    } else {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final mediaQueryData = MediaQuery.of(context);
    final size = mediaQueryData.size;
    screenWidth = size.width; // Store for use in other methods/widgets
    screenHeight = size.height; // Store for use in other methods/widgets

    final double baseCardH =
        (size.height * 0.25).clamp(180.0, 320.0); // collapsed-height reference
    final double imgH = baseCardH * 0.70;
    final restaurant =
        context.watch<FetchedResults>().fetchedResults[widget.index];

    return Dismissible(
      key: ValueKey('expanded_${widget.index}'),
      onDismissed: _handleDismiss,
      background: _swipeBg(
          color: Colors.green,
          icon: Icons.map,
          left: true,
          screenWidth: screenWidth),
      secondaryBackground: _swipeBg(
          color: Colors.red,
          icon: Icons.delete,
          left: false,
          screenWidth: screenWidth),
      child: GestureDetector(
        onTap: () {
          setState(() => _showContent = false);
          Future.delayed(const Duration(milliseconds: 150), widget.onCollapse);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.opacity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(.1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (_, __) => [
                  SliverToBoxAdapter(
                    child: _Header(
                      imgH: imgH,
                      cardH: baseCardH,
                      restaurant: restaurant,
                      screenWidth: screenWidth, // Pass screenWidth
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      screenWidth: screenWidth, // Pass screenWidth
                      tabBar: TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        labelStyle: TextStyle(
                            fontSize: (screenWidth * 0.04)
                                .clamp(14.0, 18.0), // Dynamic font size
                            fontWeight: FontWeight.w600),
                        unselectedLabelStyle: TextStyle(
                            fontSize: (screenWidth * 0.04)
                                .clamp(14.0, 18.0)), // Dynamic font size
                        tabs: const [
                          Tab(text: '簡介'),
                          Tab(text: '菜單'),
                          Tab(text: '評論'),
                        ],
                      ),
                    ),
                  ),
                ],
                body: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showContent ? 1 : 0,
                  child: TabBarView(
                    physics: _showContent
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      _IntroPane(
                          restaurant: restaurant,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                      _MenuPane(
                          restaurant: restaurant, screenWidth: screenWidth),
                      _ReviewPane(
                          restaurant: restaurant, screenWidth: screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(
          {required Color color,
          required IconData icon,
          required bool left,
          required double screenWidth}) =>
      Container(
        color: color,
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05), // Dynamic padding
        child: Icon(icon,
            color: Colors.white,
            size: (screenWidth * 0.07).clamp(24.0, 32.0)), // Dynamic icon size
      );
}

/* ──────────── sticky TabBar delegate (height = preferredSize) ──────────── */
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final double screenWidth; // Add screenWidth
  const _TabBarDelegate(
      {required this.tabBar, required this.screenWidth}); // Modify constructor

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(color: Colors.grey[50], child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

/* ───────────────────── HEADER (unchanged) ───────────────────── */
class _Header extends StatelessWidget {
  const _Header({
    required this.imgH,
    required this.cardH,
    required this.restaurant,
    required this.screenWidth, // Add screenWidth
  });

  final double imgH;
  final double cardH;
  final RestaurantOutput restaurant;
  final double screenWidth; // Store screenWidth

  @override
  Widget build(BuildContext context) {
    final double titleFont = (cardH * 0.09).clamp(16.0, 24.0);
    final double digitFont = (cardH * 0.32).clamp(28.0, 40.0);
    final double dotFont = (cardH * 0.16).clamp(14.0, 20.0);
    final double smallTextFont = (cardH * 0.05).clamp(10.0, 14.0);
    final double descriptionTextFont = (cardH * 0.06).clamp(12.0, 16.0);

    final setting = context.read<UserSetting>();
    final topScores = ScoreUtils.topTwo(restaurant, setting.sortedPreference);
    String p1Label = topScores[0].key;
    String p2Label = topScores[1].key;
    String p1Desc;
    String p2Desc;

    if (p1Label == '偏好') {
      final tag =
          ScoreUtils.bestPreferenceTag(restaurant, setting.sortedPreference);
      if (tag.isNotEmpty) p1Label = tag;
      p1Desc = restaurant.reasons[p1Label] ?? '';
    } else {
      p1Desc = restaurant.reasons[p1Label] ?? '';
    }

    if (p2Label == '偏好') {
      final tag =
          ScoreUtils.bestPreferenceTag(restaurant, setting.sortedPreference);
      if (tag.isNotEmpty) p2Label = tag;
      p2Desc = restaurant.reasons[p2Label] ?? '';
    } else {
      p2Desc = restaurant.reasons[p2Label] ?? '';
    }
    final String p1Score =
        ScoreUtils.scaleToFive(topScores[0].value).toString();
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
        : restaurant.reason;
    if (description.isEmpty) description = restaurant.input.summary;

    return Padding(
      padding: EdgeInsets.all(
          (screenWidth * 0.04).clamp(12.0, 20.0)), // Dynamic padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: imgH, // imgH is already relative
                height: imgH,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Icon(Icons.image,
                        size: imgH * 0.5)), // Relative icon size
              ),
              SizedBox(
                  width:
                      (screenWidth * 0.03).clamp(8.0, 16.0)), // Dynamic spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: FontWeight.bold)),
                    SizedBox(
                        height:
                            (cardH * 0.03).clamp(4.0, 10.0)), // Dynamic spacing
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(ratingInt,
                            style: TextStyle(
                                fontSize: digitFont,
                                fontWeight: FontWeight.bold)),
                        Text(ratingDec, style: TextStyle(fontSize: dotFont)),
                        const SizedBox(width: 4),
                        Text('分', style: TextStyle(fontSize: smallTextFont)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: (cardH * 0.04).clamp(8.0, 16.0)), // Dynamic spacing
          Text(description.isNotEmpty ? description : '無餐廳簡介',
              style: TextStyle(fontSize: descriptionTextFont)),
          SizedBox(
              height: (cardH * 0.05)
                  .clamp(10.0, 20.0)), // Dynamic spacing for pills
          _PillBlock(
            label: p1Label,
            score: p1Score,
            desc: p1Desc.isNotEmpty ? p1Desc : '無相關推薦原因',
            cardH: cardH, // Pass cardH
            screenWidth: screenWidth, // Pass screenWidth
          ),
          SizedBox(height: (cardH * 0.05).clamp(10.0, 20.0)), // Dynamic spacing
          _PillBlock(
            label: p2Label,
            score: p2Score,
            desc: p2Desc.isNotEmpty ? p2Desc : '無相關推薦原因',
            cardH: cardH, // Pass cardH
            screenWidth: screenWidth, // Pass screenWidth
          ),
          SizedBox(height: (cardH * 0.04).clamp(8.0, 16.0)), // Dynamic spacing
        ],
      ),
    );
  }
}

class _PillBlock extends StatelessWidget {
  final String label;
  final String score;
  final String desc;
  final double cardH; // Add cardH
  final double screenWidth; // Add screenWidth

  const _PillBlock(
      {required this.label,
      required this.score,
      required this.desc,
      required this.cardH, // Modify constructor
      required this.screenWidth}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    final double circleSize = (cardH * 0.12).clamp(24.0, 32.0);
    final double scoreFontSize = (cardH * 0.06).clamp(12.0, 16.0);
    final double labelFontSize = (cardH * 0.065).clamp(13.0, 17.0);
    final double descFontSize = (cardH * 0.06).clamp(12.0, 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize, // Dynamic size
              height: circleSize, // Dynamic size
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(score,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: scoreFontSize, // Dynamic font size
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                width:
                    (screenWidth * 0.015).clamp(4.0, 8.0)), // Dynamic spacing
            Text(label,
                style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.bold)), // Dynamic font size
          ],
        ),
        SizedBox(height: (cardH * 0.025).clamp(3.0, 7.0)), // Dynamic spacing
        Text(desc,
            style: TextStyle(fontSize: descFontSize)), // Dynamic font size
      ],
    );
  }
}

/* ────────────── TAB PAGES (unchanged from previous) ────────────── */

class _IntroPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  final double screenWidth;
  final double screenHeight;
  const _IntroPane(
      {required this.restaurant,
      required this.screenWidth,
      required this.screenHeight});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(
            (screenWidth * 0.04).clamp(12.0, 20.0)), // Dynamic padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoBlock(
                title: '簡介',
                body: restaurant.fullIntroduction.isNotEmpty
                    ? restaurant.fullIntroduction
                    : (restaurant.shortIntroduction.isNotEmpty
                        ? restaurant.shortIntroduction
                        : '無介紹'),
                screenWidth: screenWidth,
                screenHeight: screenHeight), // Pass screenHeight
            SizedBox(
                height:
                    (screenHeight * 0.02).clamp(12.0, 20.0)), // Dynamic spacing
            _InfoBlock(
                title: '營業時間',
                body: restaurant.input.opening ? '營業中' : '未營業',
                screenWidth: screenWidth,
                screenHeight: screenHeight), // Pass screenHeight
            SizedBox(
                height:
                    (screenHeight * 0.01).clamp(6.0, 12.0)), // Dynamic spacing
            _InfoBlock(
                title: '距離',
                body: '${restaurant.input.distance.toStringAsFixed(0)} m',
                screenWidth: screenWidth,
                screenHeight: screenHeight), // Pass screenHeight
          ],
        ),
      );
}

class _MenuPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  final double screenWidth;
  const _MenuPane({required this.restaurant, required this.screenWidth});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(
            (screenWidth * 0.04).clamp(12.0, 20.0)), // Dynamic padding
        child: Text(
          restaurant.menu.isNotEmpty ? restaurant.menu : '無菜單資訊',
          style: TextStyle(
              fontSize:
                  (screenWidth * 0.035).clamp(12.0, 16.0)), // Dynamic font size
        ),
      );
}

class _ReviewPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  final double screenWidth;
  const _ReviewPane({required this.restaurant, required this.screenWidth});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.all(
            (screenWidth * 0.04).clamp(12.0, 20.0)), // Dynamic padding
        child: Text(
          restaurant.reviews.isNotEmpty ? restaurant.reviews : '無評論資訊',
          style: TextStyle(
              fontSize:
                  (screenWidth * 0.035).clamp(12.0, 16.0)), // Dynamic font size
        ),
      );
}

/* ────────────── misc helpers ────────────── */
class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;
  final double screenWidth;
  final double screenHeight; // Add screenHeight
  const _InfoBlock(
      {required this.title,
      required this.body,
      required this.screenWidth,
      required this.screenHeight}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    final titleFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 17.0);
    final spacing = (screenHeight * 0.005).clamp(3.0, 6.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: titleFontSize, fontWeight: FontWeight.bold)),
        SizedBox(height: spacing), // Dynamic spacing
        Text(body, style: TextStyle(fontSize: bodyFontSize)),
      ],
    );
  }
}
// _MenuItem and _Bullet are not directly used in the visible part of ExpandedCard's TabBarView.
// If they were, their internal fixed sizes would need similar dynamic adjustments.
// For brevity, and as they are not in the direct rendering path of the provided screenshots/structure,
// their detailed refactoring is omitted here but would follow the same principles.
