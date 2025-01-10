// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Bishop extends ChessPiece {
  Bishop(PlayerColor color, Position position) : super(color, 'bishop', position);

  @override
  Bishop copyWith({Position? position}) {
    return Bishop(color, position ?? this.position);
  }
  

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-bishop.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx = (toPosition.col - position.col).abs();
    int dy = (toPosition.row - position.row).abs();

    // Bishop moves diagonally: equal number of rows and columns (|dx| == |dy|)
    if (dx == dy) {
      // Check if the path is clear (no pieces blocking)
      int stepX = (toPosition.col - position.col) > 0 ? 1 : -1;
      int stepY = (toPosition.row - position.row) > 0 ? 1 : -1;

      int x = position.col + stepX;
      int y = position.row + stepY;

      while (x != toPosition.col && y != toPosition.row) {
        if (!board.isEmpty(Position(row: y, col: x))) {
          return false; // There's a piece blocking the path
        }
        x += stepX;
        y += stepY;
      }

      // Make sure the destination square is either empty or occupied by an opponent's piece
      if (board.isEmpty(toPosition) || board.getPiece(toPosition)!.color != color) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];
    List<List<int>> directions = [
      [1, 1], [1, -1], [-1, 1], [-1, -1]
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
