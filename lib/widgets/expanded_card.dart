import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/restaurant_output.dart';

class ExpandedCard extends StatefulWidget {
  final int index;
  final RestaurantOutput restaurant;
  final VoidCallback onCollapse;
  final VoidCallback onDelete;
  final double opacity;

  const ExpandedCard({
    super.key,
    required this.index,
    required this.restaurant,
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
                      index: widget.index,
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
                    children: const [
                      _IntroPane(),
                      _MenuPane(),
                      _ReviewPane(),
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
    required this.index,
  });

  final double imgH;
  final double cardH;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double titleFont = cardH * 0.09;
    final double digitFont = cardH * 0.32;
    final double dotFont = cardH * 0.16;
    final String priceRating = (index + 3).toString();

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
                    Text('品田牧場日式豬排咖哩',
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('4',
                            style: TextStyle(
                                fontSize: digitFont,
                                fontWeight: FontWeight.bold)),
                        Text('.7', style: TextStyle(fontSize: dotFont)),
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
          const Text('如果你想吃咖哩，品田牧場提供多樣的日式咖哩料理', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          _PillBlock(
            label: '價格',
            score: priceRating,
            desc:
                '主餐價格多在100至200元之間，根據你設定的預算在100元以下，建議可以選擇豬排咖哩或平日午間套餐，更划算又能吃得超有飽足感！',
          ),
          const SizedBox(height: 16),
          _PillBlock(
            label: '口味',
            score: '5',
            desc: '日式咖哩香氣濃郁、滋味溫潤，搭配外酥內嫩的炸豬排，每一口都讓人安心又滿足，絕對是想吃咖哩時值得推薦的好去處！',
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
  const _IntroPane();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _InfoBlock(
                title: '簡介',
                body: '品田牧場是王品集團旗下的日式炸豬排專門店，提供多樣化的日式餐點，包括各式豬排和咖哩料理。'),
            SizedBox(height: 16),
            _InfoBlock(title: '營業時間', body: '1:00–20:00 (營業中)'),
            SizedBox(height: 8),
            _InfoBlock(title: '距離', body: '247 m'),
          ],
        ),
      );
}

class _MenuPane extends StatelessWidget {
  const _MenuPane();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MenuItem(
              name: '香酥豬排咖哩套餐', price: '\$289', desc: '（主食、白飯、味噌湯、小菜、甜點、飲品）'),
          _MenuItem(name: '厚切里肌豬排咖哩', price: '\$309', desc: '（豬排厚切特別搭配經典咖哩醬）'),
          _MenuItem(name: '海老可樂餅咖哩套餐', price: '\$259', desc: '（日式炸蝦可樂餅，香酥綿密）'),
        ],
      );
}

class _ReviewPane extends StatelessWidget {
  const _ReviewPane();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Bullet(text: '免費加飯服務：「有評論提到，這裡提供免費加飯服務，讓顧客可以享受更豐富的白飯，特別適合愛吃飯的人。」'),
          _Bullet(text: '豐富的咖哩與豬排口感：「咖哩非常濃郁，豬排外酥內嫩，每一口都非常滿足，回味無窮。」'),
          _Bullet(text: '寬敞友善座區：「餐廳設有寬敞友善區，能讓客群帶毛小孩一起來用餐，對喜歡帶寵物出門的人來說是個加分項。」'),
        ],
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
