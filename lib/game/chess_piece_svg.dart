import 'package:flutter/material.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChessPieceSvg extends StatelessWidget {
  final ChessPiece chessPiece;

  const ChessPieceSvg({super.key, required this.chessPiece});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      chessPiece.getSvgAssetPath(),

      // colorFilter: ColorFilter.mode(chessPiece.color
      // != PieceColor.white ? Colors.white : Colors.black, BlendMode.color),
      width: 50.0,
      height: 50.0,
    );
  }
}
