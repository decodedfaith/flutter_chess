// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class Bishop extends ChessPiece {
  Bishop(PieceColor color, Position position) : super(color, 'bishop', position);

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
  
  getValidMoves(){
    return;
  }
}
