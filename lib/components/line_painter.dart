import 'package:crossword/components/line_decoration.dart';
import 'package:crossword/components/word_line.dart';
import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<WordLine> lineList;
  final List<List<String>> letters;
  final Offset spacing;
  final List<String> hints;
  final Color? correctColor;
  final TextStyle? textStyle;
  final Offset shakeAnimationValue;
  final double scaleAnimationValue;
  final Offset? revealLetterPositions;
  final LineDecoration? lineDecoration;

  LinePainter({
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.lineDecoration,
    required this.shakeAnimationValue,
    required this.scaleAnimationValue,
    required this.letters,
    required this.lineList,
    required this.spacing,
    required this.hints,
    this.revealLetterPositions,
    this.correctColor = Colors.green,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = lineDecoration!.strokeWidth!
      ..isAntiAlias = true
      ..strokeCap = lineDecoration!.strokeCap!;

    ///paint lines on the grid
    for (var word in lineList) {
      ///set the line color
      ///
      if (word.colors.isEmpty) {
        paint.color = Colors.blue;
      } else if (word.colors.length < 2) {
        paint.color = word.colors.first;
      } else {
        paint.shader = LinearGradient(
          colors: word.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromPoints(word.offsets.first.getBiggerOffset,
            word.offsets.last.getBiggerOffset));
      }

      for (int i = 0; i < word.offsets.length - 1; i++) {
        canvas.drawLine(word.offsets[i].getBiggerOffset,
            word.offsets[i + 1].getBiggerOffset, paint);
      }
    }
    List<List<Offset>> offsets = [];
    if (lineList.isNotEmpty) {
      offsets = lineList
          .map((e) => e.offsets.map((e) => e.getSmallerOffset).toList())
          .toList();
    }

    ///paint texts on the grid
    for (int i = 0; i < letters.length; i++) {
      for (int j = 0; j < letters.first.length; j++) {
        double x = i.toDouble() * spacing.dx + spacing.dx / 2;
        double y = j.toDouble() * spacing.dy + spacing.dy / 2;

        Offset offset = Offset(i.toDouble(), j.toDouble());

        bool within = withinOffset(offsets, offset);

        /// Draw letters
        //draw circles
        bool reveal =
            revealLetterPositions != null && revealLetterPositions == offset;
        TextPainter painter = TextPainter(
          text: TextSpan(
            text: letters[i][j],
            style: (within ? lineDecoration?.lineTextStyle : textStyle)
                ?.copyWith(
                    fontSize:
                        ((within ? lineDecoration?.lineTextStyle : textStyle)
                                ?.fontSize)! *
                            (reveal ? scaleAnimationValue : 1)),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );

        painter.layout();
        painter.paint(
            canvas,
            Offset(x - painter.width / 2, y - painter.height / 2) +
                (reveal ? shakeAnimationValue : Offset.zero));
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;

  bool withinOffset(List<List<Offset>> offsetList, Offset offset) {
    bool within = false;
    for (var offsets in offsetList) {
      if (isPointOnLineSegment(offset, offsets.first, offsets.last)) {
        within = true;
        break;
      }
    }
    return within;
  }

  bool isPointOnLineSegment(Offset p, Offset a, Offset b) {
    // Calculate the cross product

    if (a.dx == b.dx && a.dy == b.dy) {
      return false;
    }
    double crossProduct =
        (p.dy - a.dy) * (b.dx - a.dx) - (p.dx - a.dx) * (b.dy - a.dy);

    // Check if the point is collinear with the line segment
    if (crossProduct.abs() > 1e-10) {
      return false;
    }

    // Check if the point is within the bounds of the line segment
    double dotProduct =
        (p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy);
    if (dotProduct < 0) {
      return false;
    }

    double squaredLengthBA =
        (b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy);
    if (dotProduct > squaredLengthBA) {
      return false;
    }

    return true;
  }
}
