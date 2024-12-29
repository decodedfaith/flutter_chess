// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_piece.dart';

class King extends ChessPiece {
  King(PieceColor color) : super(color, 'king');
  
  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-king.svg';
  }
  
  getValidMoves(){
    return;
  }

}
