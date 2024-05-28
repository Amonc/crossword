import 'package:crossword/components/letter_offset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordLine extends ChangeNotifier {
  final List<List<String>> letters;
  final List<LetterOffset> offsets;
  final bool acceptReversedDirection;
  List<Color> colors;

  int xSign = 0;
  int ySign = 0;

  WordLine(
      {required this.offsets,
      required this.colors,
      required this.letters,
      this.acceptReversedDirection = false});

  ///get all the offsets that fell in a drawn line
  List<Offset> get getTotalOffsets {
    Offset firstOffset = offsets.first.getSmallerOffset;
    Offset lastOffset = offsets.last.getSmallerOffset;

    if (firstOffset == lastOffset) {
      return [firstOffset, lastOffset];
    } else if (firstOffset.dx == lastOffset.dx) {
      ///xSign indicates the draw direction when the line is horizontal
      xSign = (lastOffset.dy - firstOffset.dy) ~/
          (firstOffset.dy - lastOffset.dy).abs();

      return List.generate((firstOffset.dy - lastOffset.dy).abs().toInt() + 1,
          (index) => Offset(firstOffset.dx, firstOffset.dy + index * xSign));
    } else if (firstOffset.dy == lastOffset.dy) {
      ///ySign indicates the draw direction when the line is vertical
      ySign = (lastOffset.dx - firstOffset.dx) ~/
          (firstOffset.dx - lastOffset.dx).abs();
      return List.generate((firstOffset.dx - lastOffset.dx).abs().toInt() + 1,
          (index) => Offset(firstOffset.dx + index * ySign, firstOffset.dy));
    } else {
      ///xSign and ySIgn both indicates the draw direction when the line is cross towards 4 corners
      ySign = (lastOffset.dy - firstOffset.dy) ~/
          (firstOffset.dy - lastOffset.dy).abs();

      xSign = (lastOffset.dx - firstOffset.dx) ~/
          (firstOffset.dx - lastOffset.dx).abs();
      return List.generate(
          (firstOffset.dy - lastOffset.dy).abs().toInt() + 1,
          (index) => Offset(
              firstOffset.dx + index * xSign, firstOffset.dy + index * ySign));
    }
  }

  ///set the line color
  set setColors(List<Color> c) {
    colors = c;
    notifyListeners();
  }

  ///return the Word based on the selected letters
  String get word {
    List<Offset> totalOffsets = getTotalOffsets;

    String word = totalOffsets
        .map((e) {
          int x = e.dx.toInt();
          int y = e.dy.toInt();
          if (x > letters.length) {
            x -= 1;
          }
          if (x < 0) {
            x += 1;
          }
          if (y > letters.first.length) {
            y -= 1;
          }
          if (y < 0) {
            y += 1;
          }

          return letters[x][y];
        })
        .toList()
        .join();

    ///identifies if the line can be drawn on a reversed direction or not.
    if (acceptReversedDirection) {
      return word;
    } else {
      return xSign + ySign < 0 ? word.split('').reversed.join() : word;
    }
  }
}
