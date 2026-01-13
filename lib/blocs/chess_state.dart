import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

abstract class ChessState {
  final ChessBoard board;
  final Position? lastMoveFrom;
  final Position? lastMoveTo;
  final Duration whiteTimeRemaining;
  final Duration blackTimeRemaining;
  final bool isReviewMode;
  final bool isFlipped;

  const ChessState({
    required this.board,
    this.lastMoveFrom,
    this.lastMoveTo,
    this.whiteTimeRemaining = const Duration(minutes: 10),
    this.blackTimeRemaining = const Duration(minutes: 10),
    this.isReviewMode = false,
    this.isFlipped = false,
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
    super.isReviewMode,
    super.isFlipped,
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
    super.isReviewMode,
    super.isFlipped,
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
    super.isReviewMode,
    super.isFlipped,
  });
}

enum GameEndReason {
  checkmate,
  stalemate,
  resignation,
  timeout,
}

class GameEnded extends ChessState {
  final PlayerColor? winner;
  final GameEndReason reason;
  final int moveCount;

  const GameEnded({
    this.winner,
    required this.reason,
    required this.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
    super.isReviewMode,
    super.isFlipped,
  });
}

// Deprecated: Use GameEnded instead. Keeping for backward compatibility temporarily.
class Checkmate extends GameEnded {
  const Checkmate({
    required super.winner,
    required super.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
    super.isFlipped,
  }) : super(reason: GameEndReason.checkmate);
}

class Stalemate extends GameEnded {
  const Stalemate({
    required super.moveCount,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
    super.isFlipped,
  }) : super(reason: GameEndReason.stalemate);
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
    super.isFlipped,
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
    super.isFlipped,
  });
}

class ReviewingGame extends ChessState {
  final int currentMoveIndex;

  const ReviewingGame({
    required this.currentMoveIndex,
    required super.board,
    super.lastMoveFrom,
    super.lastMoveTo,
    super.whiteTimeRemaining,
    super.blackTimeRemaining,
    super.isFlipped,
  }) : super(isReviewMode: true);
}
