// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Knight extends ChessPiece {
  Knight(PlayerColor color, Position position) : super(color, 'knight', position);

  @override
  Knight copyWith({Position? position}) {
    return Knight(color, position ?? this.position);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-knight.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx = (toPosition.col - position.col).abs();
    int dy = (toPosition.row - position.row).abs();

    // Knight moves in an "L" shape (2 squares in one direction, 1 in the other)
    if ((dx == 2 && dy == 1) || (dx == 1 && dy == 2)) {
      // It can jump over other pieces, so no need to check for empty squares
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
      [2, 1], [2, -1], [-2, 1], [-2, -1],
      [1, 2], [1, -2], [-1, 2], [-1, -2]
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
