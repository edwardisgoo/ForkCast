// lib/pages/main_page.dart
//
// ORIGINAL UI & animation logic UNCHANGED.
// ★ Additions marked with “★”.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/services/navigation.dart';
import '../widgets/title_text.dart';
import '../providers/rating_provider.dart'; // ★ new
import '../widgets/cast_helper.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _startAnim = false;
  final GlobalKey _titleKey = GlobalKey();

  /* ─ helpers (unchanged) ─ */
  double _titleEndY(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    final top = MediaQuery.of(ctx).padding.top;
    return 2 * (top + 16 + 15) / size.height - 1;
  }

  double _castEndY(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    final bottom = MediaQuery.of(ctx).padding.bottom;
    return 2 * (size.height - bottom - 16 - 30) / size.height - 1;
  }

  Widget _buildCastBtn({VoidCallback? onPressed}) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          textStyle: const TextStyle(fontSize: 28),
        ),
        child: const Text('Cast!', style: TextStyle(color: Colors.white)),
      );

  /* ───────── rating-prompt helper ───────── */
  bool _dialogShown = false;

  void _maybeAskForRating(BuildContext ctx) {
    if (_dialogShown) return;

    final prov = ctx.read<RatingProvider>();
    if (!prov.pending) return; // nothing to rate

    _dialogShown = true;
    final restName = prov.restaurantName ?? '這家餐廳';

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) {
        int stars = 0;
        return AlertDialog(
          title: Text('為「$restName」評分'),
          content: StatefulBuilder(
            builder: (c, setState) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(i < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber),
                  onPressed: () => setState(() => stars = i + 1),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                prov.clearPending(); // skip
                Navigator.pop(dCtx);
              },
              child: const Text('跳過'),
            ),
            TextButton(
              onPressed: () {
                // (store stars if needed)
                prov.clearPending();
                Navigator.pop(dCtx);
              },
              child: const Text('送出'),
            ),
          ],
        );
      },
    ).then((_) => _dialogShown = false);
  }

  /* ─ reset flag after hot-restart ─ */ // ★ new
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.read<RatingProvider>().pending) {
      _dialogShown = false;
    }
  }

  /* ───────── CAST pressed ───────── */
  void _onCast() {
    // ★ block navigation if rating still pending
    final prov = context.read<RatingProvider>();
    if (prov.pending) {
      _maybeAskForRating(context);
      return;
    }

    setState(() => _startAnim = true);

    final ctx = _titleKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      debugPrint(
          '[MAIN] title start pos=${box.localToGlobal(Offset.zero)} size=${box.size}');
    }

    performCast(context).then((_) {
      if (!mounted) return;
      final ctx = _titleKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        debugPrint(
            '[MAIN] title end pos=${box.localToGlobal(Offset.zero)} size=${box.size}');
      }
      context.read<NavigationService>().goResult();
    });
  }

  /* ───────────────────────── */
  @override
  Widget build(BuildContext context) {
    // show rating after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeAskForRating(context);
    });

    /* static alignments (start positions) */
    const titleStart = Alignment(0, -0.40);
    const castStart = Alignment(0, -0.15);
    const detailPos = Alignment(0, 0.03);

    return Scaffold(
      body: Stack(
        children: [
          /* settings + 細節搜尋 */
          AnimatedOpacity(
            opacity: _startAnim ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (context.read<RatingProvider>().pending) {
                        // ★
                        _maybeAskForRating(context);
                        return;
                      }
                      context.read<NavigationService>().goPreference();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.settings, color: Colors.black),
                    ),
                  ),
                ),
                Align(
                  alignment: detailPos,
                  child: ElevatedButton(
                    onPressed: () {
                      if (context.read<RatingProvider>().pending) {
                        // ★
                        _maybeAskForRating(context);
                        return;
                      }
                      context.read<NavigationService>().goComplexCast();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('細節搜尋'),
                  ),
                ),
              ],
            ),
          ),

          /* shrinking / sliding TITLE */
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: _startAnim ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
            builder: (context, value, child) {
              final fontSize = 58 - (28 * value); // 58 → 30
              final y =
                  titleStart.y + ((_titleEndY(context) - titleStart.y) * value);
              return Align(
                alignment: Alignment(0, y),
                child: TitleText(key: _titleKey, fontSize: fontSize),
              );
            },
          ),

          /* sliding Cast! button (Hero) */
          AnimatedAlign(
            alignment:
                _startAnim ? Alignment(0, _castEndY(context)) : castStart,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
            child: Hero(
              tag: 'castBtn',
              flightShuttleBuilder: (_, __, ___, ____, toCtx) => toCtx.widget,
              child: _buildCastBtn(onPressed: _onCast),
            ),
          ),
        ],
      ),
    );
  }
}
