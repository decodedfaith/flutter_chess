// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class King extends ChessPiece {
  King(PlayerColor color, Position position) : super(color, 'king', position);
  
  @override
  King copyWith({Position? position}) {
    return King(color, position ?? this.position);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-king.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx = (toPosition.col - position.col).abs();
    int dy = (toPosition.row - position.row).abs();

    // King moves one square in any direction
    if (dx <= 1 && dy <= 1) {
      // The king can move to any adjacent square, provided it doesn't move into check
      if (board.isEmpty(toPosition) || board.getPiece(toPosition)!.color != color) {
        return true;
      }
    }
    return false;
  }
  
  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];
    List<List<int>> offsets = [
      [1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]
    ];

    for (var offset in offsets) {
      int newRow = position.row + offset[0];
      int newCol = position.col + offset[1];
      Position move = Position(row: newRow, col: newCol);

      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        if (board.isEmpty(move) || board.getPiece(move)?.color != color) {
          moves.add(move);
        }
      }
    }

    return moves.where((move) => board.isValidMove(position, move, this)).toList();
  }


}
