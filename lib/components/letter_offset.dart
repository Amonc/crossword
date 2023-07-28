import 'dart:ui';

class LetterOffset {
  final Offset spacing;
  final Offset offset;

  LetterOffset( {required this.offset,required this.spacing, });

  Offset get getSmallerOffset {
    return Offset((offset.dx ~/ spacing.dx).toDouble(),
        (offset.dy ~/ spacing.dy).toDouble());
  }

  Offset get getBiggerOffset {
    Offset smallOffset = getSmallerOffset;

    return Offset(
        smallOffset.dx * spacing.dx + spacing.dx / 2, smallOffset.dy * spacing.dy + spacing.dy / 2);
  }
}