

import 'package:crossword/components/letter_offset.dart';
import 'package:flutter/cupertino.dart';

class WordLine extends ChangeNotifier {
  final List<List<String>> letters;
  final List<LetterOffset> offsets;
  final bool acceptReversedDirection;
  Color color;

  int xSign = 0;
  int ySign = 0;

  WordLine(
      {required this.offsets,
      required this.color,
      required this.letters,
      this.acceptReversedDirection = false});

  List<Offset> get getTotalOffsets {
    Offset firstOffset = offsets.first.getSmallerOffset;
    Offset lastOffset = offsets.last.getSmallerOffset;

    if (firstOffset == lastOffset) {
      return [firstOffset, lastOffset];
    } else if (firstOffset.dx == lastOffset.dx) {
      xSign = (lastOffset.dy - firstOffset.dy) ~/
              (firstOffset.dy - lastOffset.dy).abs();

      return List.generate((firstOffset.dy - lastOffset.dy).abs().toInt() + 1,
          (index) => Offset(firstOffset.dx, firstOffset.dy + index * xSign));
    } else if (firstOffset.dy == lastOffset.dy) {
      ySign = (lastOffset.dx - firstOffset.dx) ~/
              (firstOffset.dx - lastOffset.dx).abs();
      return List.generate((firstOffset.dx - lastOffset.dx).abs().toInt() + 1,
          (index) => Offset(firstOffset.dx + index * ySign, firstOffset.dy));
    } else {
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

  set setColor(Color c) {
    color = c;
    notifyListeners();
  }

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

    if (acceptReversedDirection) {
      return word;
    } else {
      return xSign + ySign < 0 ? word.split('').reversed.join() : word;
    }
  }
}
