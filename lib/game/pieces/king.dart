// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class King extends ChessPiece {
  King(PieceColor color, Position position) : super(color, 'king', position);
  
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
  
  getValidMoves(){
    return;
  }

}
