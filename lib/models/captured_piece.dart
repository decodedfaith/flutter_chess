import 'package:flutter_chess/models/player_color.dart';

/// Lightweight model for captured pieces (memory-optimized)
class CapturedPiece {
  final String type; // 'pawn', 'knight', 'bishop', 'rook', 'queen'
  final PlayerColor color;

  const CapturedPiece({
    required this.type,
    required this.color,
  });

  /// Get material value for this piece type
  int get value {
    switch (type) {
      case 'pawn':
        return 1;
      case 'knight':
      case 'bishop':
        return 3;
      case 'rook':
        return 5;
      case 'queen':
        return 9;
      default:
        return 0;
    }
  }

  /// Get SVG asset path for this piece
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-$type.svg';
  }
}
