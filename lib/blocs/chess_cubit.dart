import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/utils/audio_service.dart';
import 'package:flutter_chess/utils/check_detector.dart';

class ChessCubit extends Cubit<ChessState> {
  final ChessBoard _chessBoard = ChessBoard();
  ChessPiece? selectedPiece;
  Position? selectedPosition;
  Timer? _timer;
  Duration whiteTime = const Duration(minutes: 10);
  Duration blackTime = const Duration(minutes: 10);

  int get moveHistoryLength => _chessBoard.moveHistory.length;

  ChessCubit() : super(ChessInitial(board: ChessBoard())) {
    initializeBoard(); // Initialize board on creation
  }

  void initializeBoard({Duration timeLimit = const Duration(minutes: 10)}) {
    _chessBoard.initializeBoard();
    whiteTime = timeLimit;
    blackTime = timeLimit;
    _timer?.cancel();

    emit(ChessInitial(
      board: _chessBoard,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
    ));

    // Force a second emit
    Future.delayed(const Duration(milliseconds: 10), () {
      if (isClosed) return;
      emit(ChessInitial(
        board: _chessBoard,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
      _startTimer(); // Start the clock immediately
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_chessBoard.currentTurn == PlayerColor.white) {
        whiteTime -= const Duration(seconds: 1);
        if (whiteTime.inSeconds <= 0) {
          _handleTimeout(PlayerColor.white);
        }
      } else {
        blackTime -= const Duration(seconds: 1);
        if (blackTime.inSeconds <= 0) {
          _handleTimeout(PlayerColor.black);
        }
      }

      // Emit time update (preserving other state if possible, or re-emitting current state class)
      // Since State classes are distinct, we need to know WHICH state to emit.
      // Easiest is to emit MoveMade/CheckState/GameInProgress with updated times.
      // BUT, we don't want to re-trigger sounds or "last move" animations if unnecessary.
      // ChessState holds everything.

      if (state is! GameEnded) {
        emit(_copyStateWithTime(state));
      } else {
        timer.cancel();
      }
    });
  }

  void _handleTimeout(PlayerColor loser) {
    _timer?.cancel();
    AudioService().playGameOverSound();
    emit(GameEnded(
      winner:
          loser == PlayerColor.white ? PlayerColor.black : PlayerColor.white,
      reason: GameEndReason.timeout,
      moveCount: _chessBoard.moveCount,
      board: _chessBoard,
      lastMoveFrom: state.lastMoveFrom,
      lastMoveTo: state.lastMoveTo,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
    ));
  }

  ChessState _copyStateWithTime(ChessState currentState) {
    // Helper to clone state with new time
    if (currentState is CheckState) {
      return CheckState(
        colorInCheck: currentState.colorInCheck,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      );
    } else if (currentState is MoveMade) {
      return MoveMade(
        currentTurn: currentState.currentTurn,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      );
    } else if (currentState is ChessInitial) {
      // Should we transition to GameInProgress? Valid match has started if timer is ticking.
      return GameInProgress(
        board: currentState.board,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      );
    }

    return GameInProgress(
      board: currentState.board,
      lastMoveFrom: currentState.lastMoveFrom,
      lastMoveTo: currentState.lastMoveTo,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
    );
  }

  void makeMove(Position from, Position to) {
    try {
      // Validate move legality (Check rules, Pins, etc.)
      final piece = _chessBoard.getPiece(from);
      if (piece == null) {
        throw Exception("No piece at source");
      }

      final legalMoves = CheckDetector.getLegalMoves(_chessBoard, piece, from);
      if (!legalMoves.contains(to)) {
        // Move is illegal (puts king in check, or violates other rules)
        // If it was a Pseudo-valid move (geometry ok) but Illegal (Check), we catch it here.
        // We can just return or emit error. Emitting error provides feedback.
        // Check if it was at least pseudo-valid to give specific error?
        // For now, generic illegal move.
        // Actually, if we just return, the UI might stay in selected state?
        // Let's emit error to reset selection or notify user?
        // Or just ignore? "Move not allowed". error message is good.
        emit(ChessError(
            message: "Illegal move: King would be in check",
            board: _chessBoard));
        return;
      }

      // Check for capture BEFORE moving
      final isCapture = _chessBoard.getPiece(to) != null;

      // Detect Promotion BEFORE moving on board
      if (piece is Pawn && (to.row == 1 || to.row == 8)) {
        emit(AwaitingPromotion(
          promotionFrom: from,
          promotionTo: to,
          board: _chessBoard,
          whiteTimeRemaining: whiteTime,
          blackTimeRemaining: blackTime,
        ));
        return; // Stop here, wait for UI selection
      }

      _chessBoard.movePiece(from, to); // Make the move
      _emitGameStateAfterMove(from, to, isCapture);
    } catch (e) {
      // Emit ChessError state in case of exceptions
      emit(ChessError(
        message: e.toString(),
        board: _chessBoard,
        lastMoveFrom: state.lastMoveFrom,
        lastMoveTo: state.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    }
  }

  void completePromotion(Position from, Position to, String type) {
    try {
      final isCapture = _chessBoard.getPiece(to) != null;
      _chessBoard.movePiece(from, to, promotionPieceType: type);
      _emitGameStateAfterMove(from, to, isCapture);
    } catch (e) {
      emit(ChessError(
        message: e.toString(),
        board: _chessBoard,
        lastMoveFrom: state.lastMoveFrom,
        lastMoveTo: state.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    }
  }

  void _emitGameStateAfterMove(Position from, Position to, bool isCapture) {
    // Use CheckDetector for all rule validation to verify checkmate/check/stalemate correctly
    if (CheckDetector.isCheckmate(_chessBoard, _chessBoard.currentTurn)) {
      _timer?.cancel(); // Stop timer on valid end game
      AudioService().playGameOverSound();
      emit(GameEnded(
        winner: _chessBoard.currentTurn == PlayerColor.white
            ? PlayerColor.black
            : PlayerColor.white,
        reason: GameEndReason.checkmate,
        moveCount: _chessBoard.moveCount,
        board: _chessBoard,
        lastMoveFrom: from,
        lastMoveTo: to,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    } else if (CheckDetector.isKingInCheck(
        _chessBoard, _chessBoard.currentTurn)) {
      AudioService().playCheckSound();
      _startTimer();
      emit(CheckState(
        colorInCheck: _chessBoard.currentTurn,
        board: _chessBoard,
        lastMoveFrom: from,
        lastMoveTo: to,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    } else if (CheckDetector.isStalemate(
        _chessBoard, _chessBoard.currentTurn)) {
      _timer?.cancel();
      AudioService().playGameOverSound();
      emit(GameEnded(
        reason: GameEndReason.stalemate,
        moveCount: _chessBoard.moveCount,
        board: _chessBoard,
        lastMoveFrom: from,
        lastMoveTo: to,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    } else {
      if (isCapture) {
        AudioService().playCaptureSound();
      } else {
        AudioService().playMoveSound();
      }
      _startTimer();
      emit(MoveMade(
        currentTurn: _chessBoard.currentTurn,
        board: _chessBoard,
        lastMoveFrom: from,
        lastMoveTo: to,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));
    }
  }

  void resign() {
    _timer?.cancel();
    emit(GameEnded(
      winner: _chessBoard.currentTurn == PlayerColor.white
          ? PlayerColor.black
          : PlayerColor.white,
      reason: GameEndReason.resignation,
      moveCount: _chessBoard.moveCount,
      board: _chessBoard,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
    ));
  }

  void startReviewMode() {
    if (_chessBoard.moveHistory.isEmpty) return;
    jumpToMove(_chessBoard.moveHistory.length - 1);
  }

  void jumpToMove(int index) {
    if (index < -1 || index >= _chessBoard.moveHistory.length) return;

    // To review, we create a fresh board and replay moves up to 'index'
    final reviewBoard = ChessBoard();
    reviewBoard.initializeBoard();

    for (int i = 0; i <= index; i++) {
      final move = _chessBoard.moveHistory[i];
      reviewBoard.movePiece(move.from, move.to,
          promotionPieceType: move.promotionType);
    }

    final lastMove = index >= 0 ? _chessBoard.moveHistory[index] : null;

    emit(ReviewingGame(
      currentMoveIndex: index,
      board: reviewBoard,
      lastMoveFrom: lastMove?.from,
      lastMoveTo: lastMove?.to,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
    ));
  }

  void nextMove() {
    if (state is ReviewingGame) {
      jumpToMove((state as ReviewingGame).currentMoveIndex + 1);
    }
  }

  void previousMove() {
    if (state is ReviewingGame) {
      jumpToMove((state as ReviewingGame).currentMoveIndex - 1);
    }
  }

  void selectPiece(Position position) {
    // Logic to select the piece and highlight valid moves
    ChessPiece? piece = _chessBoard.getPiece(position);
    if (piece != null) {
      selectedPiece = piece;
      selectedPosition = position;

      // Emit state with the updated board and piece selection
      emit(MoveMade(
        currentTurn: _chessBoard.currentTurn,
        board: _chessBoard,
        lastMoveFrom: state.lastMoveFrom,
        lastMoveTo: state.lastMoveTo,
      ));
    }
  }

  void resetGame() {
    initializeBoard(); // Reinitialize board
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
