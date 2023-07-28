library crossword;

import 'dart:math';

import 'package:crossword/components/letter_offset.dart';
import 'package:crossword/components/line_decoration.dart';
import 'package:crossword/components/line_painter.dart';
import 'package:crossword/components/word_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Crossword extends StatefulWidget {
  final List<List<String>> letters;
  final LineDecoration? lineDecoration;
  final Offset spacing;
  final bool? drawCrossLine;
  final bool? drawHorizontalLine;
  final bool? drawVerticalLine;
  final Function(List<String> words) onLineDrawn;
  final List<String> hints;
  final TextStyle? textStyle;
  final bool? acceptReversedDirection;

  const Crossword(
      {super.key,
      required this.letters,
      required this.spacing,
      this.drawCrossLine,
      required this.onLineDrawn,
      this.drawHorizontalLine,
      this.drawVerticalLine,
      required this.hints,
      this.lineDecoration = const LineDecoration(),
      this.textStyle,
      this.acceptReversedDirection=false})
      : assert(
          (drawCrossLine ?? true) ||
              (drawHorizontalLine ?? true) ||
              (drawVerticalLine ?? true),
          "At least one of drawCrossLine, drawHorizontalLine, or drawVerticalLine should be true",
        );

  @override
  CrosswordState createState() => CrosswordState();
}

class CrosswordState extends State<Crossword> {
  List<WordLine> lineList = [];
  List<Offset> selectedOffsets = [];
  Color? color;

  List<WordLine> updatedLineList = [];
  LetterOffset? startPoint;
  LetterOffset? endPoint;

  bool isWithinLimit(LetterOffset offset) {
    return !(offset.getSmallerOffset.dx < 0 ||
        offset.getSmallerOffset.dx > widget.letters.length - 1 ||
        offset.getSmallerOffset.dy < 0 ||
        offset.getSmallerOffset.dy > widget.letters.first.length - 1);
  }

  bool isHorizontalLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    }

    double firstY = offsets.first.getSmallerOffset.dy;

    for (LetterOffset offset in offsets) {
      if (offset.getSmallerOffset.dy != firstY) {
        return false;
      }
    }

    return true;
  }

  bool isVerticalLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    }

    double firstX = offsets.first.getSmallerOffset.dx;

    for (LetterOffset offset in offsets) {
      if (offset.getSmallerOffset.dx != firstX) {
        return false;
      }
    }

    return true;
  }

  bool isCrossLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    }

    for (int x = 0; x < offsets.length; x++) {
      if (x > 0) {
        int a = offsets[x].getSmallerOffset.dx.toInt() -
            offsets[x - 1].getSmallerOffset.dx.toInt();
        int b = offsets[x].getSmallerOffset.dy.toInt() -
            offsets[x - 1].getSmallerOffset.dy.toInt();

        if (a.abs() - b.abs() != 0) {
          return false;
        }
      }
    }

    return true;
  }

  Color generateRandomColor() {
    Random random = Random();
    int index = random.nextInt(widget.lineDecoration!.lineColors!.length);
    return widget.lineDecoration!.lineColors![index];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onPanStart: (DragStartDetails details) {
                color = generateRandomColor();

                setState(() {
                  startPoint = LetterOffset(
                      offset: details.localPosition, spacing: widget.spacing);
                  endPoint = LetterOffset(
                      offset: details.localPosition, spacing: widget.spacing);
                  lineList.add(WordLine(
                      offsets: [startPoint!, endPoint!],
                      color: color!,
                      letters: widget.letters,
                      acceptReversedDirection:
                          widget.acceptReversedDirection!));
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  final dx = details.localPosition.dx - startPoint!.offset.dx;
                  final dy = details.localPosition.dy - startPoint!.offset.dy;

                  double angle = atan2(dy, dx);

                  // Round the angle to the nearest multiple of 45 degrees
                  angle = (angle / (pi / 4)).round() * (pi / 4);

                  final length = sqrt(dx * dx + dy * dy);
                  final restrictedDx = cos(angle) * length;
                  final restrictedDy = sin(angle) * length;
                  LetterOffset c = LetterOffset(
                      offset: Offset(startPoint!.offset.dx + restrictedDx,
                          startPoint!.offset.dy + restrictedDy),
                      spacing: widget.spacing);
                  if (isWithinLimit(c)) {
                    endPoint = c;
                    lineList.last = WordLine(
                        offsets: [startPoint!, endPoint!],
                        color: color!,
                        letters: widget.letters,
                        acceptReversedDirection:
                            widget.acceptReversedDirection!);
                  }
                });
              },
              onPanEnd: (DragEndDetails details) async {
                List<Offset> usedOffsets = lineList.last.getTotalOffsets;

                setState(() {
                  if (selectedOffsets
                          .toSet()
                          .intersection(usedOffsets.toSet())
                          .isEmpty &&
                      lineList.last.offsets
                              .map((e) => e.getSmallerOffset)
                              .toSet()
                              .length >
                          1 &&
                      (((widget.drawHorizontalLine ?? true)
                              ? isHorizontalLine(lineList.last.offsets)
                              : false) ||
                          ((widget.drawVerticalLine ?? true)
                              ? isVerticalLine(lineList.last.offsets)
                              : false) ||
                          ((widget.drawCrossLine ?? true)
                              ? isCrossLine(lineList.last.offsets)
                              : false))) {
                    selectedOffsets.addAll(usedOffsets);
                    if (widget.hints.contains(lineList.last.word)) {
                      if (widget.lineDecoration!.correctColor != null) {
                        lineList.last.color =
                            widget.lineDecoration!.correctColor!;
                      }
                    } else {
                      if (widget.lineDecoration!.incorrectColor != null) {
                        lineList.last.color =
                            widget.lineDecoration!.incorrectColor!;
                      }
                    }

                    widget.onLineDrawn(lineList.map((e) => e.word).toList());
                  } else {
                    startPoint = null;
                    endPoint = null;
                    lineList.removeLast();
                  }
                });
              },
              child: CustomPaint(
                painter: LinePainter(
                    lineDecoration: widget.lineDecoration,
                    letters: widget.letters,
                    lineList: lineList,
                    textStyle: widget.textStyle,
                    spacing: widget.spacing,
                    hints: widget.hints),
                size: Size(widget.letters.length * widget.spacing.dx,
                    widget.letters.first.length * widget.spacing.dy),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
