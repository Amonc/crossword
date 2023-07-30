library crossword;

import 'dart:math';

import 'package:crossword/components/letter_offset.dart';
import 'package:crossword/components/line_decoration.dart';
import 'package:crossword/components/line_painter.dart';
import 'package:crossword/components/word_line.dart';
import 'package:crossword/helper/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Crossword extends StatefulWidget {
  final List<List<String>> letters;
  final bool? transposeMatrix;
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
      this.acceptReversedDirection = false,
      this.transposeMatrix = false})
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
  List<List<String>> letters = [];

  @override
  void initState() {
    // TODO: implement initState
    letters =
    widget.transposeMatrix! ?widget.letters: widget.letters.transpose();
    super.initState();
  }

  //check whether user interaction on the panel within the letter positions limit or outside the area
  bool isWithinLimit(LetterOffset offset) {
    return !(offset.getSmallerOffset.dx < 0 ||
        offset.getSmallerOffset.dx > letters.length - 1 ||
        offset.getSmallerOffset.dy < 0 ||
        offset.getSmallerOffset.dy > letters.first.length - 1);
  }

//check if the drawn line on a horizontal track
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

  //check if the drawn line on a vertical track
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

//check if the drawn line on a 45 degree angled track
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

  //generate random colors based on the give line colors
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
                      letters: letters,
                      acceptReversedDirection:
                          widget.acceptReversedDirection!));
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  //get initial positions based on user interaction on the panel
                  final dx = details.localPosition.dx - startPoint!.offset.dx;
                  final dy = details.localPosition.dy - startPoint!.offset.dy;

                  double angle = atan2(dy, dx);

                  // Round the angle to the nearest multiple of 45 degrees
                  angle = (angle / (pi / 4)).round() * (pi / 4);

                  final length = sqrt(dx * dx + dy * dy);

                  //get the restricted coordinates using the angle
                  final restrictedDx = cos(angle) * length;
                  final restrictedDy = sin(angle) * length;

                  //Use a custom class to get suitable conversions
                  LetterOffset c = LetterOffset(
                      offset: Offset(startPoint!.offset.dx + restrictedDx,
                          startPoint!.offset.dy + restrictedDy),
                      spacing: widget.spacing);

                  //line can only be drawn by touching inside the panel
                  if (isWithinLimit(c)) {
                    endPoint = c;
                    lineList.last = WordLine(
                        offsets: [startPoint!, endPoint!],
                        color: color!,
                        letters: letters,
                        acceptReversedDirection:
                            widget.acceptReversedDirection!);
                  }
                });
              },
              onPanEnd: (DragEndDetails details) async {
                //get the last line drawn from the list
                List<Offset> usedOffsets = lineList.last.getTotalOffsets;

                setState(() {
                  //Check if the line can be drawn on specific angles
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
                        //set a line color when the selected word is correct
                        lineList.last.color =
                            widget.lineDecoration!.correctColor!;
                      }
                    } else {
                      if (widget.lineDecoration!.incorrectColor != null) {
                        //set a line color when the selected word is incorrect
                        lineList.last.color =
                            widget.lineDecoration!.incorrectColor!;
                      }
                    }

                    //return a list of word

                    widget.onLineDrawn(lineList.map((e) => e.word).toList());
                  } else {
                    startPoint = null;
                    endPoint = null;
                    lineList.removeLast();
                  }
                });
              },
              child: CustomPaint(
                //paints lines on the screen
                painter: LinePainter(
                    lineDecoration: widget.lineDecoration,
                    letters: letters,
                    lineList: lineList,
                    textStyle: widget.textStyle,
                    spacing: widget.spacing,
                    hints: widget.hints),
                size: Size(letters.length * widget.spacing.dx,
                    letters.first.length * widget.spacing.dy),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
