// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_piece.dart';

class Knight extends ChessPiece {
  Knight(PieceColor color) : super(color, 'knight');

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-knight.svg';
  }

  getValidMoves(){
    return;
  } 
}
