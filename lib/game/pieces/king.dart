// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class King extends ChessPiece {
  King(PlayerColor color, Position position, {String? id})
      : super(color, 'king', position, id: id);

  @override
  King copyWith({Position? position}) {
    return King(color, position ?? this.position, id: id);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-king.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx =
        (chessColToIndex(toPosition.col) - chessColToIndex(position.col)).abs();
    int dy = (toPosition.row - position.row).abs();

    // King moves one square in any direction
    if (dx <= 1 && dy <= 1) {
      // The king can move to any adjacent square, provided it doesn't move into check
      if (board.isEmpty(toPosition) ||
          board.getPiece(toPosition)!.color != color) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];
    List<List<int>> offsets = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ];

    for (var offset in offsets) {
      int newRow = position.row + offset[0];
      int newCol = chessColToIndex(position.col) + offset[1];

      // Correct bounds: rows are 1-8, cols are 0-7
      if (newRow >= 1 && newRow <= 8 && newCol >= 0 && newCol < 8) {
        Position move = Position(row: newRow, col: indexToChessCol(newCol));
        if (board.isEmpty(move) || board.getPiece(move)?.color != color) {
          moves.add(move);
        }
      }
    }

    return moves; // Check validation happens separately
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
