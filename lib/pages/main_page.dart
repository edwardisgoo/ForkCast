import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import '../widgets/title_text.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey _titleKey = GlobalKey();
  bool _start = false;

  void _onCast() {
    setState(() => _start = true);

    // log after animation
    Future.delayed(const Duration(milliseconds: 650), () => _log('[M]'));

    // navigate to ResultPage
    Future.delayed(const Duration(milliseconds: 1000), () {
      Provider.of<NavigationService>(context, listen: false).goResult();
    });
  }

  void _log(String p) {
    final ctx = _titleKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      debugPrint('$p title pos=${box.localToGlobal(Offset.zero)} '
          'size=${box.size}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;

    // -------- fractional Y -------------
    const double startTitleY = -0.40;
    final double endTitleY = 2 * (safeTop + 16 + 15) / size.height - 1;

    const double startBtnY = -0.15;
    final double endBtnY = 2 * (size.height - 16 - 30) / size.height - 1;
    const double detailY = 0.03;
    // -----------------------------------

    return Scaffold(
      body: Stack(
        children: [
          // settings + 細節搜尋 fade
          AnimatedOpacity(
            opacity: _start ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Stack(children: [
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => nav.goPreference(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.settings, color: Colors.black),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, detailY),
                child: ElevatedButton(
                  onPressed: () => nav.goComplexCast(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('細節搜尋'),
                ),
              ),
            ]),
          ),

          // ✨ title: slide + simultaneous shrink
          AnimatedAlign(
            alignment: Alignment(0, _start ? endTitleY : startTitleY),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 58,
                end: _start ? 30 : 58,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutSine,
              builder: (_, value, __) => Hero(
                tag: 'pageTitle',
                flightShuttleBuilder: (_, __, ___, ____, toCtx) => toCtx.widget,
                child: TitleText(key: _titleKey, fontSize: value),
              ),
            ),
          ),

          // 🚀 Cast! button
          AnimatedAlign(
            alignment: Alignment(0, _start ? endBtnY : startBtnY),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
            child: ElevatedButton(
              onPressed: _onCast,
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
