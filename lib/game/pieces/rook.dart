import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class Rook extends ChessPiece {
  Rook(PieceColor color, Position position) : super(color, 'rook', position);

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-rook.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    if (toPosition.row == position.row || toPosition.col == position.col) {
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

  getValidMoves(){
    return;
  }
}