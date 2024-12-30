import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class Pawn extends ChessPiece {
  Pawn(PieceColor color, Position position) : super(color, 'pawn', position);

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-pawn.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int direction = color == PieceColor.white ? 1 : -1;  // White moves up, black moves down
    int startRow = color == PieceColor.white ? 1 : 6;  // Start rows for white (1) and black (6)

    // Moving forward one square
    if (toPosition.row == position.row + direction && toPosition.col == position.col && board.isEmpty(toPosition)) {
      return true;
    }
    
    // Moving forward two squares (only on the first move)
if (position.row == startRow &&
    toPosition.row == position.row + 2 * direction &&
    toPosition.col == position.col &&
    board.isEmpty(toPosition) &&
    board.isEmpty(Position(row: position.row + direction, col: position.col))) {
  return true;
}

    // Capturing diagonally
    if (toPosition.row == position.row + direction &&
        (toPosition.col == position.col + 1 || toPosition.col == position.col - 1) &&
        !board.isEmpty(toPosition) &&
        board.getPiece(toPosition)!.color != color) {
      return true;
    }

    return false;
  }

  getValidMoves(){
    return;
  }
}