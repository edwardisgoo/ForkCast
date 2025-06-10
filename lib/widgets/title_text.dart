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
