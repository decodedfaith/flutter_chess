import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/models/player_color.dart';

abstract class ChessState {
  final ChessBoard board;

  ChessState(this.board);
}

class ChessInitial extends ChessState {
  ChessInitial(super.board);
}

class MoveMade extends ChessState {
  final PlayerColor currentTurn; // Whose turn is next
  MoveMade(this.currentTurn, super.board);
}

class CheckState extends ChessState {
  final PlayerColor colorInCheck; // 'White' or 'Black'
  CheckState(this.colorInCheck, super.board);
}

class Checkmate extends ChessState {
  final PlayerColor winner; // 'White' or 'Black'
  Checkmate(this.winner, super.board);
}

class Stalemate extends ChessState {
  Stalemate(super.board);
}

class ChessError extends ChessState {
  final String message;
  ChessError(this.message, super.board);
}
