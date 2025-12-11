import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/models/player_color.dart';

abstract class ChessState {
  final ChessBoard board;

  const ChessState({required this.board});
}

class ChessInitial extends ChessState {
  const ChessInitial({required super.board});
}

class GameInProgress extends ChessState {
  const GameInProgress({required super.board});
}

class MoveMade extends GameInProgress {
  final PlayerColor currentTurn;

  const MoveMade({
    required this.currentTurn,
    required super.board,
  });
}

/// State when a king is in check
class CheckState extends GameInProgress {
  final PlayerColor colorInCheck;

  const CheckState({
    required this.colorInCheck,
    required super.board,
  });
}

class Checkmate extends ChessState {
  final PlayerColor winner;
  final int moveCount;

  const Checkmate({
    required this.winner,
    required this.moveCount,
    required super.board,
  });
}

class Stalemate extends ChessState {
  final int moveCount;

  const Stalemate({
    required this.moveCount,
    required super.board,
  });
}

class Resignation extends ChessState {
  final PlayerColor resignedPlayer;
  final int moveCount;

  const Resignation({
    required this.resignedPlayer,
    required this.moveCount,
    required super.board,
  });
}

class ChessError extends ChessState {
  final String message;

  const ChessError({
    required this.message,
    required super.board,
  });
}
