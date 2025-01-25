// lib/utils/position_utils.dart

import 'package:flutter_chess/game/position.dart';

class PositionUtils {
  /// Converts algebraic notation (e.g., "e4") to a Position object
  static Position fromAlgebraic(String notation) {
    if (notation.length != 2) {
      throw ArgumentError("Invalid algebraic notation: $notation");
    }

    int col = notation.codeUnitAt(0) - 'a'.codeUnitAt(0); // Convert 'a' to 0, 'b' to 1, etc.
    int row = 8 - int.parse(notation[1]); // Convert '1' to 7, '2' to 6, etc.

    return Position(row: row, col: String.fromCharCode('a'.codeUnitAt(0) + col));
  }

  /// Converts a Position object to algebraic notation (e.g., "e4")
  static String toAlgebraic(Position position) {
    String file = position.col; // Use Position's colLetter getter to convert column index to letter
    String rank = (8 - position.row).toString(); // Convert row index to chessboard rank

    return "$file$rank";
  }

  static int manhattanDistance(Position pos1, Position pos2) {
  int ans = ((pos1.row - pos2.row) + ((pos1.col.codeUnitAt(0) - 'a'.codeUnitAt(0)) - pos2.col.codeUnitAt(0) - 'a'.codeUnitAt(0))).toInt();
  return ans;
}


  /// Checks if two positions are diagonally aligned
  static bool isDiagonal(Position pos1, Position pos2) {
    return (pos1.row - pos2.row).abs() == ((pos1.col.codeUnitAt(0) - 'a'.codeUnitAt(0)) - (pos2.col.codeUnitAt(0) - 'a'.codeUnitAt(0))).abs();
  }

  /// Checks if two positions are in the same rank (row)
  static bool isSameRank(Position pos1, Position pos2) {
    return pos1.row == pos2.row;
  }

  /// Checks if two positions are in the same file (column)
  static bool isSameFile(Position pos1, Position pos2) {
    return pos1.col == pos2.col;
  }

  int chessColToIndex(String col) {
    // Convert chess column ('a'-'h') to array index (0-7)
    return col.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  String indexToChessCol(int colIndex) {
    // Convert array index (0-7) to chess column ('a'-'h')
    return String.fromCharCode('a'.codeUnitAt(0) + colIndex);
  }
}
