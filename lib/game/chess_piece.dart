import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';

enum PieceColor {
  white,
  black;

  // Method to return the enum name as a string
  String get name => toString().split('.').last;
}

abstract class ChessPiece {
  final PieceColor color;
  Position position;
  final String type;

  ChessPiece(this.color, this.type, this.position);

  // Abstract method to get SVG asset path
  String getSvgAssetPath();

  bool isValidMove(Position toPosition, ChessBoard board);
}
