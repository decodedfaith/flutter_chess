// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_piece.dart';

class Bishop extends ChessPiece {
  Bishop(PieceColor color) : super(color, 'bishop');

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-bishop.svg';
  }
  getValidMoves(){
    return;
  }
}
