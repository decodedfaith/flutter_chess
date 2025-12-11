import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter_chess/game/chess_piece.dart';

class PieceComponent extends SvgComponent {
  final ChessPiece piece;

  PieceComponent({required this.piece})
      : super(
          priority: 1, // Piece above board
          anchor: Anchor.topLeft, // Align to top-left of square
        );

  @override
  Future<void> onLoad() async {
    // Load the SVG for the piece
    final svg =
        await Svg.load(piece.getSvgAssetPath().replaceFirst('assets/', ''));
    this.svg = svg;

    // Ensure SVG scales to fit the component size
    // Size will be set by BoardComponent during creation
    await super.onLoad();
  }
}
