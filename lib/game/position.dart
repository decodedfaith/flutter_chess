// lib/game/chess_piece.dart

class Position {
  final int row;  // Corresponds to rows (1 to 8, where row 0 is the 1st row on the board)
  final int col;  // Corresponds to columns (0 to 7, where column 0 is 'a', column 7 is 'h')

  Position({required this.row, required this.col});

  // Convert the column index to a letter for better visualization (e.g., 0 -> 'a', 1 -> 'b')
  String get colLetter => String.fromCharCode(col + 97);

  // Convert the position to the standard chess notation (e.g., 0, 0 -> 'a1')
  String get notation => '${colLetter}${8 - row}';

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
    int col = notation.codeUnitAt(0) - 97;  // Convert 'a' to 0, 'b' to 1, etc.
    int row = 8 - int.parse(notation[1]);  // Convert '1' to 7, '8' to 0, etc.
    return Position(row: row, col: col);
  }
}

