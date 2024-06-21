import 'package:flutter/animation.dart';

/// To decorate the reveal letter animation
class RevealLetterDecoration {
  final Offset shakeOffset;
  final double scaleFactor;
  final Duration animationDuration;
  final Curve shakeCurve, scaleCurve;

  const RevealLetterDecoration(
      {this.shakeOffset = const Offset(40, 0),
      this.scaleFactor = 3,
      this.shakeCurve = Curves.elasticIn,
      this.scaleCurve = Curves.easeInOut,
      this.animationDuration = const Duration(milliseconds: 1000)});
}
