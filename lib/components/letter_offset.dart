import 'dart:ui';

class LetterOffset {
  final Offset spacing;
  final Offset offset;

  LetterOffset({
    required this.offset,
    required this.spacing,
  });

  //get the smaller converted offsets ex:(0,0.. 0,1)
  Offset get getSmallerOffset {
    return Offset((offset.dx ~/ spacing.dx).toDouble(),
        (offset.dy ~/ spacing.dy).toDouble());
  }

  //get the bigger offsets by filtering the spacing horizontally and vertically ex:(0,0..0,30) when spacing set to 30
  Offset get getBiggerOffset {
    Offset smallOffset = getSmallerOffset;

    return Offset(smallOffset.dx * spacing.dx + spacing.dx / 2,
        smallOffset.dy * spacing.dy + spacing.dy / 2);
  }
}
