///transpose the 2x2 matrix
extension TransposeMatrixExtension on List<List<String>> {
  List<List<String>> transpose() {
    if (isEmpty || this[0].isEmpty) {
      throw ArgumentError("List must not be empty.");
    }

    int rows = length;
    int cols = this[0].length;

    /// Initialize the transposed list with empty lists
    List<List<String>> transposedList = List.generate(cols, (_) => []);

    for (int i = 0; i < rows; i++) {
      if (this[i].length != cols) {
        throw ArgumentError("Input list must have consistent row lengths.");
      }
      for (int j = 0; j < cols; j++) {
        transposedList[j].add(this[i][j]);
      }
    }

    return transposedList;
  }
}
