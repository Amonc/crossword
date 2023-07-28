
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

  final LineDecoration? lineDecoration;

  LinePainter(  {
    this.textStyle= const TextStyle(color: Colors.black, fontSize: 16),
    this.lineDecoration=const LineDecoration(),

    required this.letters,
    required this.lineList,
    required this.spacing,
    required this.hints,
    this.correctColor=Colors.green,

  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = lineDecoration!.strokeWidth!
      ..isAntiAlias=true
      ..strokeCap =lineDecoration!.strokeCap!;


    //paint lines on the grid
    for (var points in lineList) {



      paint.color = points.color;

      for (int i = 0; i < points.offsets.length - 1; i++) {
        canvas.drawLine(points.offsets[i].getBiggerOffset,
            points.offsets[i + 1].getBiggerOffset, paint);

      }
    }

    //paint texts on the grid
    for (int i = 0; i < letters.length; i++) {
      for (int j = 0; j < letters.first.length; j++) {
        double x = i.toDouble() * spacing.dx + spacing.dx / 2;
        double y = j.toDouble() * spacing.dy + spacing.dy / 2;

        // Draw letters
        TextPainter painter = TextPainter(
          text: TextSpan(
            text: letters[i][j],
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        painter.layout();
        painter.paint(
            canvas, Offset(x - painter.width / 2, y - painter.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
