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

  String toAlgebraic() => notation;

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
    String col = notation[0];
    int row = int.parse(notation[1]);
    return Position(row: row, col: col);
  }

  factory Position.fromAlgebraic(String algebraic) =>
      Position.fromNotation(algebraic);
}
