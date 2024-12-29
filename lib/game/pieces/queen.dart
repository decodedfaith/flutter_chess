// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_piece.dart';

class Queen extends ChessPiece {
  Queen(PieceColor color) : super(color, 'queen');
  
  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-queen.svg';
  }

  getValidMoves(){
    return;
  }
}
