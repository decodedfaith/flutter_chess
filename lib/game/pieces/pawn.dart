import 'package:flutter_chess/game/chess_piece.dart';

class Pawn extends ChessPiece {
  Pawn(PieceColor color) : super(color, 'pawn');

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-pawn.svg';
  }

  getValidMoves(){
    return;
  }
}