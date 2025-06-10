import 'package:flutter/material.dart';

/// Base style shared by both pages (no size yet)
const TextStyle _baseTitleStyle = TextStyle(
  fontFamily: 'Courier',
  fontWeight: FontWeight.bold,
  height: 1, // exact line-height → predictable height = fontSize
);

/// Same TextHeightBehavior everywhere
const TextHeightBehavior _beh = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Convenience to create a StrutStyle with identical height = 1
StrutStyle _strut(double size) => StrutStyle(fontSize: size, height: 1);

/// Re-usable title widget; supply only the fontSize.
class TitleText extends StatelessWidget {
  const TitleText({super.key, required this.fontSize});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ForkCast!',
      style: _baseTitleStyle.copyWith(fontSize: fontSize),
      strutStyle: _strut(fontSize),
      textHeightBehavior: _beh,
      textAlign: TextAlign.center,
    );
  }
}

/// Title rendered with a white stroke around black fill. Useful for
/// lightweight loading screens.
class OutlinedTitle extends StatelessWidget {
  const OutlinedTitle({super.key, required this.fontSize});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'ForkCast!',
          style: _baseTitleStyle.copyWith(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.white,
          ),
          strutStyle: _strut(fontSize),
          textHeightBehavior: _beh,
          textAlign: TextAlign.center,
        ),
        Text(
          'ForkCast!',
          style: _baseTitleStyle.copyWith(
            fontSize: fontSize,
            color: Colors.black,
          ),
          strutStyle: _strut(fontSize),
          textHeightBehavior: _beh,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Animated version of [OutlinedTitle] that sequentially bounces each
/// letter of "ForkCast" while it is displayed.
class BouncingTitle extends StatefulWidget {
  const BouncingTitle({super.key, required this.fontSize});
  final double fontSize;

  @override
  State<BouncingTitle> createState() => _BouncingTitleState();
}

class _BouncingTitleState extends State<BouncingTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _letters = ['F', 'o', 'r', 'k', 'C', 'a', 's', 't','!'];
  static const _display = 'ForkCast!';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final idx =
            (_letters.length * _controller.value).floor() % _letters.length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _display.length; i++)
              Transform.translate(
                offset: Offset(0, i == idx ? -8 : 0),
                child: _OutlinedChar(_display[i], widget.fontSize),
              ),
          ],
        );
      },
    );
  }
}

/// Helper to draw a single outlined character.
class _OutlinedChar extends StatelessWidget {
  const _OutlinedChar(this.char, this.size);
  final String char;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          char,
          style: _baseTitleStyle.copyWith(
            fontSize: size,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 7
              ..color = Colors.white,
            decoration: TextDecoration.none,
          ),
          strutStyle: _strut(size),
          textHeightBehavior: _beh,
          textAlign: TextAlign.center,
        ),
        Text(
          char,
          style: _baseTitleStyle.copyWith(
            fontSize: size,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
          strutStyle: _strut(size),
          textHeightBehavior: _beh,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
