import 'dart:math';

import 'package:crossword/crossword.dart';
import 'package:flutter/material.dart';

/// Represents a widget for a crossword game board.
class Crossword extends StatefulWidget {
  final bool? addIncorrectWord;
  final List<List<String>> letters;
  final bool? transposeMatrix;
  final List<Color>? invalidLineColors;
  final LineDecoration? lineDecoration;
  final Offset spacing;
  final bool? drawCrossLine;
  final bool? drawHorizontalLine;
  final bool? drawVerticalLine;
  final Function(List<String> words) onLineDrawn;
  final Function(String word)? onLineUpdate;
  final List<String> hints;
  final TextStyle? textStyle;
  final bool? acceptReversedDirection;
  final bool? allowOverlap;
  final bool? updateStateWithParent;
  final List<LineOffset> initialLineList;
  final int minimumWordLength;
  final LetterPopDecoration letterPopDecoration;

  final RevealLetterDecoration? revealLetterDecoration;

  const Crossword({
    super.key,
    required this.letters,
    required this.spacing,
    this.drawCrossLine,
    required this.onLineDrawn,
    this.drawHorizontalLine,
    this.drawVerticalLine,
    required this.hints,
    this.lineDecoration,
    this.textStyle,
    this.initialLineList = const [],
    this.acceptReversedDirection = false,
    this.transposeMatrix = false,
    this.allowOverlap = false,
    this.addIncorrectWord = true,
    this.onLineUpdate,
    this.invalidLineColors,
    this.revealLetterDecoration = const RevealLetterDecoration(
        shakeOffset: Offset(20, 50), scaleFactor: 2),
    this.updateStateWithParent = false,
    this.minimumWordLength = 3,
    this.letterPopDecoration = const LetterPopDecoration(),
  }) : assert(
          (drawCrossLine ?? true) ||
              (drawHorizontalLine ?? true) ||
              (drawVerticalLine ?? true),
          "At least one of drawCrossLine, drawHorizontalLine, or drawVerticalLine should be true",
        );

  @override
  CrosswordState createState() => CrosswordState();
}

/// State class for the Crossword widget.
class CrosswordState extends State<Crossword> with TickerProviderStateMixin {
  List<WordLine> lineList = [];
  List<Offset> selectedOffsets = [];
  List<Color> colors = [];

  List<WordLine> updatedLineList = [];
  LetterOffset? startPoint;
  LetterOffset? endPoint;
  List<List<String>> letters = [];
  late AnimationController _revealHintAnimationController;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  Offset? currentOffset;

  late AnimationController _popAnimationController;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    /// TODO: implement initState
    letters =
        widget.transposeMatrix! ? widget.letters : widget.letters.transpose();
    super.initState();
    setupInitialLines();

    ///initialize the animation controller
    _revealHintAnimationController = AnimationController(
      duration: widget.revealLetterDecoration!.animationDuration,
      vsync: this,
    );

    ///set the shake and scale animation
    _shakeAnimation = Tween<Offset>(
            begin: Offset.zero, end: widget.revealLetterDecoration!.shakeOffset)
        .chain(CurveTween(curve: widget.revealLetterDecoration!.shakeCurve))
        .animate(_revealHintAnimationController);

    ///set the scale animation
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.revealLetterDecoration!.scaleFactor,
    )
        .chain(CurveTween(curve: widget.revealLetterDecoration!.scaleCurve))
        .animate(_revealHintAnimationController);

    _popAnimationController = AnimationController(
      vsync: this,
      duration: widget.letterPopDecoration.duration,
    )..repeat(reverse: true);

    _popAnimation = Tween<double>(
            begin: 1, end: widget.letterPopDecoration.onTouchPopScaleFactor)
        .chain(CurveTween(curve: widget.letterPopDecoration.curve))
        .animate(_popAnimationController);
  }

  Offset revealLetterPositions = const Offset(0, 0);

  ///animate the panel would be called using GlobalKey<CrosswordState>
  animate({required Offset offset}) {
    revealLetterPositions = offset;
    setState(() {});
    _revealHintAnimationController
        .forward()
        .then((value) => _revealHintAnimationController.reverse());
  }

  @override
  void dispose() {
    _revealHintAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Crossword oldWidget) {
    /// TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.updateStateWithParent!) {
      letters =
          widget.transposeMatrix! ? widget.letters : widget.letters.transpose();
      lineList = [];
      selectedOffsets = [];
      updatedLineList = [];
    }
  }

  ///check whether user interaction on the panel within the letter positions limit or outside the area
  bool isWithinLimit(LetterOffset offset) {
    return !(offset.getSmallerOffset.dx < 0 ||
        offset.getSmallerOffset.dx > letters.length - 1 ||
        offset.getSmallerOffset.dy < 0 ||
        offset.getSmallerOffset.dy > letters.first.length - 1);
  }

  ///check if the drawn line on a horizontal track
  bool isHorizontalLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    } else if (offsets.first == offsets.last) {
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

  ///check if the drawn line on a vertical track
  bool isVerticalLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    } else if (offsets.first == offsets.last) {
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

  ///check if the drawn line on a 45 degree angled track
  bool isCrossLine(List<LetterOffset> offsets) {
    if (offsets.isEmpty) {
      return false;
    } else if (offsets.first == offsets.last) {
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

  ///generate random colors based on the give line colors
  List<Color> generateRandomColors() {
    Random random = Random();
    int index =
        random.nextInt(widget.lineDecoration!.lineGradientColors.length);
    return widget.lineDecoration!.lineGradientColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onPanStart: (DragStartDetails details) {
                colors = generateRandomColors();

                setState(() {
                  startPoint = LetterOffset(
                      offset: details.localPosition, spacing: widget.spacing);
                  endPoint = LetterOffset(
                      offset: details.localPosition, spacing: widget.spacing);
                  WordLine wordLine = WordLine(
                    offsets: [startPoint!, endPoint!],
                    colors: colors,
                    letters: letters,
                    acceptReversedDirection: widget.acceptReversedDirection!,
                  );

                  lineList.add(wordLine);
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  ///get initial positions based on user interaction on the panel
                  final dx = details.localPosition.dx - startPoint!.offset.dx;
                  final dy = details.localPosition.dy - startPoint!.offset.dy;

                  double angle = atan2(dy, dx);

                  /// Round the angle to the nearest multiple of 45 degrees
                  angle = (angle / (pi / 4)).round() * (pi / 4);

                  final length = sqrt(dx * dx + dy * dy);

                  ///get the restricted coordinates using the angle
                  final restrictedDx = cos(angle) * length;
                  final restrictedDy = sin(angle) * length;

                  ///Use a custom class to get suitable conversions
                  LetterOffset c = LetterOffset(
                      offset: Offset(startPoint!.offset.dx + restrictedDx,
                          startPoint!.offset.dy + restrictedDy),
                      spacing: widget.spacing);

                  if (currentOffset != c.getSmallerOffset) {
                    currentOffset = c.getSmallerOffset;
                    _popAnimationController
                        .forward()
                        .then((value) => _popAnimationController.reverse());
                  }

                  ///line can only be drawn by touching inside the panel
                  if (isWithinLimit(c)) {
                    endPoint = c;
                    WordLine wordLine = WordLine(
                      offsets: [startPoint!, endPoint!],
                      colors: colors,
                      letters: letters,
                      acceptReversedDirection: widget.acceptReversedDirection!,
                    );

                    lineList.last = wordLine;

                    bool isH = ((widget.drawHorizontalLine ?? true)
                        ? isHorizontalLine(lineList.last.offsets)
                        : false);
                    bool isV = ((widget.drawVerticalLine ?? true)
                        ? isVerticalLine(lineList.last.offsets)
                        : false);
                    bool isC = ((widget.drawCrossLine ?? true)
                        ? isCrossLine(lineList.last.offsets)
                        : false);
                    if (isC == false && isH == false && isV == false) {
                      lineList.last = WordLine(
                        offsets: [startPoint!, endPoint!],
                        colors: widget.invalidLineColors ??
                            [Colors.red.withOpacity(.2)],
                        letters: letters,
                        acceptReversedDirection:
                            widget.acceptReversedDirection!,
                      );
                      if (widget.onLineUpdate != null) {
                        if (lineList.isNotEmpty) {
                          widget.onLineUpdate!("");
                        }
                      }
                    } else {
                      if (widget.onLineUpdate != null) {
                        if (lineList.isNotEmpty) {
                          widget.onLineUpdate!(lineList.last.word);
                        }
                      }
                    }
                  }
                });
              },
              onPanEnd: (DragEndDetails details) async {
                ///get the last line drawn from the list
                bool isOverlapped;
                List<Offset> usedOffsets;
                if (lineList.isNotEmpty) {
                  usedOffsets = lineList.last.getTotalOffsets;
                  isOverlapped = ((selectedOffsets
                      .toSet()
                      .intersection(usedOffsets.toSet())
                      .isNotEmpty));
                } else {
                  isOverlapped = false;
                  usedOffsets = [];
                }

                setState(() {
                  ///Check if the line can be drawn on specific angles
                  if ((widget.minimumWordLength <= lineList.last.word.length) &&
                      ((widget.allowOverlap ?? false) || !isOverlapped) &&
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
                      if (widget.lineDecoration!.correctGradientColors !=
                          null) {
                        ///set a line color when the selected word is correct
                        lineList.last.colors =
                            widget.lineDecoration!.correctGradientColors ??
                                colors;
                      }
                    } else {
                      if (widget.addIncorrectWord ?? true) {
                        if (widget.lineDecoration!.incorrectGradientColors !=
                            null) {
                          ///set a line color when the selected word is incorrect
                          lineList.last.colors =
                              widget.lineDecoration!.incorrectGradientColors!;
                        }
                      } else {
                        lineList.removeLast();
                      }
                    }

                    ///return a list of word

                    widget.onLineDrawn(lineList.map((e) => e.word).toList());
                  } else {
                    startPoint = null;
                    endPoint = null;
                    lineList.removeLast();
                  }
                });
              },
              child: AnimatedBuilder(
                animation: _popAnimationController,
                builder: (BuildContext context, Widget? child) {
                  return AnimatedBuilder(
                    animation: _revealHintAnimationController,
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        ///paints lines on the screen
                        painter: LinePainter(
                            currentOffset: currentOffset,
                            revealLetterPositions: revealLetterPositions,
                            popAnimationValue: _popAnimation.value,
                            scaleAnimationValue: _scaleAnimation.value,
                            shakeAnimationValue: _shakeAnimation.value,
                            lineDecoration: widget.lineDecoration,
                            letters: letters,
                            lineList: lineList,
                            textStyle: widget.textStyle,
                            spacing: widget.spacing,
                            hints: widget.hints),
                        size: Size(letters.length * widget.spacing.dx,
                            letters.first.length * widget.spacing.dy),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void setupInitialLines() {
    List<WordLine> wordLines = widget.initialLineList
        .map((e) => WordLine(
              offsets: [
                LetterOffset.fromSmallerOffsets(e.start, widget.spacing),
                LetterOffset.fromSmallerOffsets(e.end, widget.spacing)
              ],
              colors: widget.lineDecoration!.lineGradientColors.first,
              letters: ((widget.transposeMatrix ?? false)
                  ? widget.letters
                  : widget.letters.transpose()),
            ))
        .toList();

    wordLines = wordLines
        .map((wordLine) => WordLine(
              offsets: wordLine.offsets,
              colors: getColors(wordLine: wordLine),
              letters: wordLine.letters,
              acceptReversedDirection: widget.acceptReversedDirection!,
            ))
        .toList();

    lineList = wordLines;

    selectedOffsets
        .addAll(lineList.map((e) => e.getTotalOffsets).expand((e) => e));
    setState(() {});
  }

  List<Color> getColors({required WordLine wordLine}) {
    if (widget.hints.contains(wordLine.word)) {
      return widget.lineDecoration!.correctGradientColors ?? wordLine.colors;
    } else {
      return widget.lineDecoration!.incorrectGradientColors ?? wordLine.colors;
    }
  }
}
