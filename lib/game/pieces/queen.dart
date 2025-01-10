// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Queen extends ChessPiece {
  Queen(PlayerColor color, Position position) : super(color, 'queen', position);
  
  @override
  Queen copyWith({Position? position}) {
    return Queen(color, position ?? this.position);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-queen.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx = (toPosition.col - position.col).abs();
    int dy = (toPosition.row - position.row).abs();

    // Queen moves like both a Rook (horizontal/vertical) and Bishop (diagonal)
    if (dx == dy || toPosition.row == position.row || toPosition.col == position.col) {
      // Check if the path is clear (no pieces blocking)
      int stepX = (toPosition.col - position.col) > 0 ? 1 : (toPosition.col < position.col ? -1 : 0);
      int stepY = (toPosition.row - position.row) > 0 ? 1 : (toPosition.row < position.row ? -1 : 0);

      int x = position.col + stepX;
      int y = position.row + stepY;

      while (x != toPosition.col || y != toPosition.row) {
        if (!board.isEmpty(Position(row: y, col: x))) {
          return false; // There's a piece blocking the path
        }
        x += stepX;
        y += stepY;
      }

      // Ensure the destination square is either empty or occupied by an opponent's piece
      if (board.isEmpty(toPosition) || board.getPiece(toPosition)!.color != color) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];

    // Combine rook and bishop movement directions
    List<List<int>> directions = [
      [0, 1], [0, -1], [1, 0], [-1, 0], // Rook
      [1, 1], [1, -1], [-1, 1], [-1, -1] // Bishop
    ];

    for (var direction in directions) {
      int newRow = position.row;
      int newCol = position.col;
      while (true) {
        newRow += direction[0];
        newCol += direction[1];
        Position next = Position(row: newRow, col: newCol);

        if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
        if (board.isEmpty(next)) {
          moves.add(next);
        } else {
          if (board.getPiece(next)?.color != color) moves.add(next);
          break;
        }
      }
    }

    return moves.where((move) => board.isValidMove(position, move, this)).toList();
  }

}
