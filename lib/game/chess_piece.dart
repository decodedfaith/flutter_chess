import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

abstract class ChessPiece {
  final PlayerColor color;
  Position position;
  final String type;

  ChessPiece(this.color, this.type, this.position);

  ChessPiece copyWith({Position? position});


  // Abstract method to get SVG asset path
  String getSvgAssetPath();

  bool isValidMove(Position toPosition, ChessBoard board);

  List<Position> getValidMoves(ChessBoard board);
}
