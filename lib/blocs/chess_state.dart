import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

abstract class ChessState {
  final ChessBoard board;
  final Position? lastMoveFrom;
  final Position? lastMoveTo;
  final Duration whiteTimeRemaining;
  final Duration blackTimeRemaining;

  const ChessState({
    required this.board,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.whiteTimeRemaining = const Duration(minutes: 10),
    this.blackTimeRemaining = const Duration(minutes: 10),
  });
}

class ChessInitial extends ChessState {
  const ChessInitial({
    required super.board,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class GameInProgress extends ChessState {
  const GameInProgress({
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class MoveMade extends GameInProgress {
  final PlayerColor currentTurn;

  const MoveMade({
    required this.currentTurn,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

/// State when a king is in check
class CheckState extends GameInProgress {
  final PlayerColor colorInCheck;

  const CheckState({
    required this.colorInCheck,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class Checkmate extends ChessState {
  final PlayerColor winner;
  final int moveCount;

  const Checkmate({
    required this.winner,
    required this.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class Stalemate extends ChessState {
  final int moveCount;

  const Stalemate({
    required this.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class Resignation extends ChessState {
  final PlayerColor resignedPlayer;
  final int moveCount;

  const Resignation({
    required this.resignedPlayer,
    required this.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class ChessError extends ChessState {
  final String message;

  const ChessError({
    required this.message,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}

class AwaitingPromotion extends GameInProgress {
  final Position promotionFrom;
  final Position promotionTo;

  const AwaitingPromotion({
    required this.promotionFrom,
    required this.promotionTo,
    required super.board,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
  });
}
