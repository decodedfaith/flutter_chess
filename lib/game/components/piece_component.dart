import 'package:flame_svg/flame_svg.dart';
import 'package:flutter_chess/game/chess_piece.dart';

class PieceComponent extends SvgComponent {
  final ChessPiece piece;

  PieceComponent({required this.piece})
      : super(priority: 1); // Piece above board

  @override
  Future<void> onLoad() async {
    // Load the SVG for the piece
    // Note: FlameSvg uses Svg.load
    final svg =
        await Svg.load(piece.getSvgAssetPath().replaceFirst('assets/', ''));
    this.svg = svg;
    super.onLoad();
  }
}
