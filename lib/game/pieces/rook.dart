import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Rook extends ChessPiece {
  Rook(PlayerColor color, Position position) : super(color, 'rook', position);

  @override
  Rook copyWith({Position? position}) {
    return Rook(color, position ?? this.position);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-rook.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    if (toPosition.row != position.row && toPosition.col != position.col) {
      return false; // Rook moves must be in the same row or column
    }

    // Determine the direction of movement
    int stepX = toPosition.col == position.col ? 0 : (toPosition.col > position.col ? 1 : -1);
    int stepY = toPosition.row == position.row ? 0 : (toPosition.row > position.row ? 1 : -1);

    // Traverse the path and check for blocking pieces
    for (int x = position.col + stepX, y = position.row + stepY;
        x != toPosition.col || y != toPosition.row;
        x += stepX, y += stepY) {
      if (!board.isEmpty(Position(row: y, col: x))) {
        return false; // Path is blocked
      }
    }

    // Validate the destination
    ChessPiece? targetPiece = board.getPiece(toPosition);
    return targetPiece == null || targetPiece.color != color;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];

    // Horizontal and vertical directions
    List<List<int>> directions = [
      [0, 1], [0, -1], [1, 0], [-1, 0]
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