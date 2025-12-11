import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:uuid/uuid.dart';

abstract class ChessPiece {
  final PlayerColor color;
  Position position;
  final String type;
  final String id;

  ChessPiece(this.color, this.type, this.position, {String? id})
      : id = id ?? const Uuid().v4();

  ChessPiece copyWith({Position? position, bool? hasMoved});

  // Abstract method to get SVG asset path
  String getSvgAssetPath();

  bool isValidMove(Position toPosition, ChessBoard board);

  List<Position> getValidMoves(ChessBoard board);
}
