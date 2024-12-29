import 'package:flutter_chess/game/chess_piece.dart';

class Rook extends ChessPiece {
  Rook(PieceColor color) : super(color, 'rook');

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-rook.svg';
  }

  getValidMoves(){
    return;
  }
}