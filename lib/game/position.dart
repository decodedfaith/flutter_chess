// lib/game/chess_piece.dart

class Position {
  final String
      col; // Corresponds to columns (a to h, where column a is the first column on the board)
  final int
      row; // Corresponds to rows (1 to 8, where row 1 is the 1st row on the board)

  Position({required this.row, required this.col});

  // Convert the column index to a letter for better visualization (e.g., 0 -> 'a', 1 -> 'b')
  // String get colLetter => String.fromCharCode(col + 97);

  // Convert the position to the standard chess notation (e.g., 0, 0 -> 'a1')
  String get notation => '$col$row';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  // Factory method to create Position from standard chess notation (e.g., 'a1' -> Position(0, 0))
  factory Position.fromNotation(String notation) {
    int col = notation.codeUnitAt(0) - 97; // Convert 'a' to 0, 'b' to 1, etc.
    int row = 8 - int.parse(notation[1]); // Convert '1' to 7, '8' to 0, etc.
    return Position(
        row: row, col: String.fromCharCode('a'.codeUnitAt(0) + col));
  }
}
