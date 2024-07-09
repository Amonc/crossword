import 'package:flutter/material.dart';

class LineDecoration {
  final List<List<Color>> lineGradientColors;

  final List<Color>? incorrectGradientColors;
  final List<Color>? correctGradientColors;
  final double? strokeWidth;
  final StrokeCap? strokeCap;
  final TextStyle? lineTextStyle;

  const LineDecoration({
    required this.lineGradientColors,
    this.incorrectGradientColors = const [Colors.red, Colors.black],
    this.correctGradientColors,
    this.strokeWidth = 20,
    this.strokeCap = StrokeCap.round,
    this.lineTextStyle = const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  });
}
