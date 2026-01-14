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
import 'package:flutter_chess/data/repositories/aegis_chess_repository.dart';
import 'package:uuid/uuid.dart';

class ChessCubit extends Cubit<ChessState> {
  final ChessBoard _chessBoard = ChessBoard();
  final AegisChessRepository _aegisRepo = AegisChessRepository();
  final String myId = const Uuid().v4();
  String activeMatchId = "default_match";

  ChessPiece? selectedPiece;
  Position? selectedPosition;
  Timer? _timer;
  Duration whiteTime = const Duration(minutes: 10);
  Duration blackTime = const Duration(minutes: 10);

  int get moveHistoryLength => _chessBoard.moveHistory.length;

  ChessCubit() : super(ChessInitial(board: ChessBoard())) {
    initializeBoard();
    _aegisRepo.init(myId);
  }

  void setupSync(String matchId) {
    activeMatchId = matchId;
    _aegisRepo.watchMoves(matchId).listen((move) {
      if (move['playerId'] != myId) {
        final from = Position.fromAlgebraic(move['from']);
        final to = Position.fromAlgebraic(move['to']);
        _handleRemoteMove(from, to, move['promotionType']);
      }
    });

    _aegisRepo.watchOpponentThinking().listen((isThinking) {
      emit(_copyWith(state, opponentIsThinking: isThinking));
    });
  }

  void _handleRemoteMove(Position from, Position to, String? promotionType) {
    final isCapture = _chessBoard.getPiece(to) != null;
    _chessBoard.movePiece(from, to, promotionPieceType: promotionType);
    _emitGameStateAfterMove(from, to, isCapture);
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

  void toggleFlip() {
    emit(_copyWith(state, isFlipped: !state.isFlipped));
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
    final opponentThinking = currentState.opponentIsThinking;
    if (currentState is CheckState) {
      return CheckState(
        colorInCheck: currentState.colorInCheck,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
        opponentIsThinking: opponentThinking,
      );
    } else if (currentState is MoveMade) {
      return MoveMade(
        currentTurn: currentState.currentTurn,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
        opponentIsThinking: opponentThinking,
      );
    } else if (currentState is ChessInitial) {
      return GameInProgress(
        board: currentState.board,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
        opponentIsThinking: opponentThinking,
      );
    }

    return GameInProgress(
      board: currentState.board,
      lastMoveFrom: currentState.lastMoveFrom,
      lastMoveTo: currentState.lastMoveTo,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
      opponentIsThinking: opponentThinking,
    );
  }

  ChessState _copyWith(ChessState currentState,
      {bool? isFlipped, bool? opponentIsThinking}) {
    final flipped = isFlipped ?? currentState.isFlipped;
    final thinking = opponentIsThinking ?? currentState.opponentIsThinking;

    if (currentState is GameEnded) {
      return GameEnded(
        winner: currentState.winner,
        reason: currentState.reason,
        moveCount: currentState.moveCount,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: currentState.whiteTimeRemaining,
        blackTimeRemaining: currentState.blackTimeRemaining,
        isReviewMode: currentState.isReviewMode,
        isFlipped: flipped,
        opponentIsThinking: thinking,
      );
    } else if (currentState is ReviewingGame) {
      return ReviewingGame(
        currentMoveIndex: currentState.currentMoveIndex,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: currentState.whiteTimeRemaining,
        blackTimeRemaining: currentState.blackTimeRemaining,
        isFlipped: flipped,
        opponentIsThinking: thinking,
      );
    } else if (currentState is CheckState) {
      return CheckState(
        colorInCheck: currentState.colorInCheck,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: currentState.whiteTimeRemaining,
        blackTimeRemaining: currentState.blackTimeRemaining,
        isReviewMode: currentState.isReviewMode,
        isFlipped: flipped,
        opponentIsThinking: thinking,
      );
    } else if (currentState is MoveMade) {
      return MoveMade(
        currentTurn: currentState.currentTurn,
        board: currentState.board,
        lastMoveFrom: currentState.lastMoveFrom,
        lastMoveTo: currentState.lastMoveTo,
        whiteTimeRemaining: currentState.whiteTimeRemaining,
        blackTimeRemaining: currentState.blackTimeRemaining,
        isReviewMode: currentState.isReviewMode,
        isFlipped: flipped,
        opponentIsThinking: thinking,
      );
    }

    return GameInProgress(
      board: currentState.board,
      lastMoveFrom: currentState.lastMoveFrom,
      lastMoveTo: currentState.lastMoveTo,
      whiteTimeRemaining: whiteTime,
      blackTimeRemaining: blackTime,
      isReviewMode: currentState.isReviewMode,
      isFlipped: flipped,
      opponentIsThinking: thinking,
    );
  }

  void makeMove(Position from, Position to) {
    try {
      onUserInputFinished();
      final piece = _chessBoard.getPiece(from);
      if (piece == null) {
        throw Exception("No piece at source");
      }

      final legalMoves = CheckDetector.getLegalMoves(_chessBoard, piece, from);
      if (!legalMoves.contains(to)) {
        emit(ChessError(
            message: "Illegal move: King would be in check",
            board: _chessBoard));
        return;
      }

      final isCapture = _chessBoard.getPiece(to) != null;

      if (piece is Pawn && (to.row == 1 || to.row == 8)) {
        emit(AwaitingPromotion(
          promotionFrom: from,
          promotionTo: to,
          board: _chessBoard,
          whiteTimeRemaining: whiteTime,
          blackTimeRemaining: blackTime,
        ));
        return;
      }

      _chessBoard.movePiece(from, to);

      _aegisRepo.pushMove(activeMatchId, {
        'from': from.toAlgebraic(),
        'to': to.toAlgebraic(),
        'playerId': myId,
        'fen': _chessBoard.toFen(),
      });

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

  void completePromotion(Position from, Position to, String type) {
    try {
      final isCapture = _chessBoard.getPiece(to) != null;
      _chessBoard.movePiece(from, to, promotionPieceType: type);

      _aegisRepo.pushMove(activeMatchId, {
        'from': from.toAlgebraic(),
        'to': to.toAlgebraic(),
        'promotionType': type,
        'playerId': myId,
        'fen': _chessBoard.toFen(),
      });

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
    if (CheckDetector.isCheckmate(_chessBoard, _chessBoard.currentTurn)) {
      _timer?.cancel();
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
    onUserInputStarted();
    ChessPiece? piece = _chessBoard.getPiece(position);
    if (piece != null) {
      selectedPiece = piece;
      selectedPosition = position;

      emit(MoveMade(
        currentTurn: _chessBoard.currentTurn,
        board: _chessBoard,
        lastMoveFrom: state.lastMoveFrom,
        lastMoveTo: state.lastMoveTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
        opponentIsThinking: state.opponentIsThinking,
      ));
    }
  }

  void onUserInputStarted() {
    _aegisRepo.setThinking(true);
  }

  void onUserInputFinished() {
    _aegisRepo.setThinking(false);
  }

  void resetGame() {
    initializeBoard();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
