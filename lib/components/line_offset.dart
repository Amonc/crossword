import 'dart:ui';

/// A class that represents a line offset
/// The line is represented by two points, start and end
class LineOffset {
  final Offset start;
  final Offset end;

  const LineOffset({required this.start, required this.end});
}
