import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/utils/score_utils.dart';
import 'package:flutter_app/models/fetchedResults.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/userSetting.dart';

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

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300),
        () => mounted ? setState(() => _showContent = true) : null);
  }

  void _handleDismiss(DismissDirection dir) {
    if (_isDismissed) return;
    setState(() {
      _isDismissed = true;
      _showContent = false;
    });

    if (dir == DismissDirection.startToEnd) {
      context.read<NavigationService>().goMaps();
      widget.onCollapse();
    } else {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final double baseCardH =
        (size.height * 0.25).clamp(180.0, 320.0); // collapsed-height reference
    final double imgH = baseCardH * 0.70;
    final restaurant =
        context.watch<FetchedResults>().fetchedResults[widget.index];

    return Dismissible(
      key: ValueKey('expanded_${widget.index}'),
      onDismissed: _handleDismiss,
      background: _swipeBg(color: Colors.green, icon: Icons.map, left: true),
      secondaryBackground:
          _swipeBg(color: Colors.red, icon: Icons.delete, left: false),
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
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      tabBar: const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: TextStyle(fontSize: 16),
                        tabs: [
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
                      _IntroPane(restaurant: restaurant),
                      _MenuPane(restaurant: restaurant),
                      _ReviewPane(restaurant: restaurant),
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
          {required Color color, required IconData icon, required bool left}) =>
      Container(
        color: color,
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.only(left: left ? 20 : 0, right: left ? 0 : 20),
        child: Icon(icon, color: Colors.white, size: 28),
      );
}

/* ──────────── sticky TabBar delegate (height = preferredSize) ──────────── */
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate({required this.tabBar});

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
  });

  final double imgH;
  final double cardH;
  final RestaurantOutput restaurant;

  @override
  Widget build(BuildContext context) {
    final double titleFont = cardH * 0.09;
    final double digitFont = cardH * 0.32;
    final double dotFont = cardH * 0.16;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
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
                        const Text('分', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description.isNotEmpty ? description : '無餐廳簡介',
              style: const TextStyle(fontSize: 14)),
          _PillBlock(
            label: p1Label,
            score: p1Score,
            desc: p1Desc.isNotEmpty ? p1Desc : '無相關推薦原因',
          ),
          const SizedBox(height: 16),
          _PillBlock(
            label: p2Label,
            score: p2Score,
            desc: p2Desc.isNotEmpty ? p2Desc : '無相關推薦原因',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PillBlock extends StatelessWidget {
  final String label;
  final String score;
  final String desc;
  const _PillBlock(
      {required this.label, required this.score, required this.desc});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(score,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 14)),
        ],
      );
}

/* ────────────── TAB PAGES (unchanged from previous) ────────────── */

class _IntroPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  const _IntroPane({required this.restaurant});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoBlock(
                title: '簡介',
                body: restaurant.fullIntroduction.isNotEmpty
                    ? restaurant.fullIntroduction
                    : (restaurant.shortIntroduction.isNotEmpty
                        ? restaurant.shortIntroduction
                        : '無介紹')),
            const SizedBox(height: 16),
            _InfoBlock(
                title: '營業時間', body: restaurant.input.opening ? '營業中' : '未營業'),
            const SizedBox(height: 8),
            _InfoBlock(
                title: '距離',
                body: '${restaurant.input.distance.toStringAsFixed(0)} m'),
          ],
        ),
      );
}

class _MenuPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  const _MenuPane({required this.restaurant});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          restaurant.menu.isNotEmpty ? restaurant.menu : '無菜單資訊',
          style: const TextStyle(fontSize: 14),
        ),
      );
}

class _ReviewPane extends StatelessWidget {
  final RestaurantOutput restaurant;
  const _ReviewPane({required this.restaurant});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          restaurant.reviews.isNotEmpty ? restaurant.reviews : '無評論資訊',
          style: const TextStyle(fontSize: 14),
        ),
      );
}

/* ────────────── misc helpers ────────────── */
class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;
  const _InfoBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 15)),
        ],
      );
}

class _MenuItem extends StatelessWidget {
  final String name;
  final String price;
  final String desc;
  const _MenuItem(
      {required this.name, required this.price, required this.desc});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                Text(price,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
          ],
        ),
      );
}
