import 'package:flutter/material.dart';

class LineDecoration {
  final List<Color>? lineColors;

  final Color? incorrectColor;
  final Color? correctColor;
  final double? strokeWidth;
  final StrokeCap? strokeCap;

  const LineDecoration(
      {this.lineColors = const [Colors.blue],
      this.incorrectColor,
      this.correctColor,
      this.strokeWidth = 20,
      this.strokeCap = StrokeCap.round});
}
