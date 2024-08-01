import 'dart:ui';

import 'package:flutter/animation.dart';

class LetterPopDecoration {
  final double onTouchPopScaleFactor;
  final FontStyle onTouchLetterFontStyle;
  final FontWeight onTouchLetterFontWeight;
  final Duration duration;
  final Curve curve;
  const LetterPopDecoration({
    this.onTouchPopScaleFactor = 1.5,
    this.onTouchLetterFontStyle = FontStyle.italic,
    this.onTouchLetterFontWeight = FontWeight.bold,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.decelerate,
  });
}
