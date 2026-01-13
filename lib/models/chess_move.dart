import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class ChessMove {
  final Position from;
  final Position to;
  final String pieceType;
  final PlayerColor color;
  final bool isCapture;
  final bool isCheck;
  final bool isCheckmate;
  final String? promotionType;
  final DateTime timestamp;

  const ChessMove({
    required this.from,
    required this.to,
    required this.pieceType,
    required this.color,
    this.isCapture = false,
    this.isCheck = false,
    this.isCheckmate = false,
    this.promotionType,
    required this.timestamp,
  });
}
