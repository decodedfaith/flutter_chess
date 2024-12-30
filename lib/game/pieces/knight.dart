// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class Knight extends ChessPiece {
  Knight(PieceColor color, Position position) : super(color, 'knight', position);

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

  getValidMoves(){
    return;
  } 
}
