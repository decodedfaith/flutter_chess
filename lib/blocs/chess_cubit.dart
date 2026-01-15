import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/utils/audio_service.dart';
import 'package:flutter_chess/utils/check_detector.dart';
import 'package:flutter_chess/data/repositories/i_chess_repository.dart';
import 'package:uuid/uuid.dart';

class ChessCubit extends Cubit<ChessState> {
  final ChessBoard _chessBoard = ChessBoard();
  final IChessRepository _aegisRepo;
  final String myId = const Uuid().v4();
  String activeMatchId = "default_match";

  ChessPiece? selectedPiece;
  Position? selectedPosition;
  Timer? _timer;
  Duration whiteTime = const Duration(minutes: 10);
  Duration blackTime = const Duration(minutes: 10);
  Duration _timeIncrement = Duration.zero; // Increment per move
  Timer? _abandonTimer;
  static const Duration _abandonTimeout = Duration(seconds: 30);
  bool _firstMoveMade = false;

  int get moveHistoryLength => _chessBoard.moveHistory.length;

  ChessCubit(this._aegisRepo) : super(ChessInitial(board: ChessBoard())) {
    _aegisRepo.init(myId);
    // Note: We don't initializeBoard() here anymore to avoid overwriting restorations
    // The UI should call initializeBoard() or restoreSession()
  }

  Future<void> _persist() async {
    final history = _chessBoard.moveHistory
        .map((m) => {
              'from': m.from.toAlgebraic(),
              'to': m.to.toAlgebraic(),
              'promotionType': m.promotionType,
            })
        .toList();

    await _aegisRepo.saveLocalState('active_game', {
      'matchId': activeMatchId,
      'fen': _chessBoard.toFen(),
      'history': history,
      'whiteTimeMs': whiteTime.inMilliseconds,
      'blackTimeMs': blackTime.inMilliseconds,
      'turn': _chessBoard.currentTurn.name, // Persist who's turn it is
      'whitePlayerName': whitePlayerName,
      'blackPlayerName': blackPlayerName,
      'lastMoveFrom': state.lastMoveFrom?.toAlgebraic(),
      'lastMoveTo': state.lastMoveTo?.toAlgebraic(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String whitePlayerName = "White";
  String blackPlayerName = "Black";

  Future<bool> restoreSession() async {
    final data = await _aegisRepo.getLocalState('active_game');
    if (data == null) return false;

    try {
      final fen = data['fen'] as String;
      activeMatchId = data['matchId'] as String;
      whiteTime = Duration(milliseconds: data['whiteTimeMs'] as int);
      blackTime = Duration(milliseconds: data['blackTimeMs'] as int);
      whitePlayerName = data['whitePlayerName'] as String? ?? "White";
      blackPlayerName = data['blackPlayerName'] as String? ?? "Black";

      // Time Catch-up Logic:
      // Subtract the time that passed while the app was "dead"
      final savedAt =
          DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
      final drift = DateTime.now().difference(savedAt);
      final currentTurnStr = data['turn'] as String? ?? 'white';

      if (currentTurnStr == 'white') {
        whiteTime -= drift;
        if (whiteTime < Duration.zero) whiteTime = Duration.zero;
      } else {
        blackTime -= drift;
        if (blackTime < Duration.zero) blackTime = Duration.zero;
      }

      _chessBoard.loadFen(fen);

      _chessBoard.moveHistory.clear();
      // In a real app we'd map back to Move objects, but loadFen handles the board state.

      _firstMoveMade = _chessBoard.moveHistory.isNotEmpty;

      final lastFrom = data['lastMoveFrom'] != null
          ? Position.fromAlgebraic(data['lastMoveFrom'])
          : null;
      final lastTo = data['lastMoveTo'] != null
          ? Position.fromAlgebraic(data['lastMoveTo'])
          : null;

      emit(GameInProgress(
        board: _chessBoard,
        lastMoveFrom: lastFrom,
        lastMoveTo: lastTo,
        whiteTimeRemaining: whiteTime,
        blackTimeRemaining: blackTime,
      ));

      _startTimer();
      return true;
    } catch (e) {
      debugPrint('[ChessCubit] Restoration failed: $e');
      return false;
    }
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

  void initializeBoard({
    Duration timeLimit = const Duration(minutes: 10),
    Duration increment = Duration.zero,
    String whiteName = "White",
    String blackName = "Black",
  }) {
    _chessBoard.initializeBoard();
    whiteTime = timeLimit;
    blackTime = timeLimit;
    _timeIncrement = increment;
    whitePlayerName = whiteName;
    blackPlayerName = blackName;
    _firstMoveMade = false;
    _timer?.cancel();
    _abandonTimer?.cancel();

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
      _startAbandonTimer(); // Start abandon timer
    });
  }

  void toggleFlip() {
    emit(_copyWith(state, isFlipped: !state.isFlipped));
  }

  DateTime? _turnStartTime;
  Duration? _whiteTimeAtTurnStart;
  Duration? _blackTimeAtTurnStart;

  void _startTimer() {
    _timer?.cancel();
    _turnStartTime = DateTime.now();
    _whiteTimeAtTurnStart = whiteTime;
    _blackTimeAtTurnStart = blackTime;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (_turnStartTime == null || state is GameEnded) {
      _timer?.cancel();
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_turnStartTime!);

    if (_chessBoard.currentTurn == PlayerColor.white) {
      whiteTime = _whiteTimeAtTurnStart! - elapsed;
      if (whiteTime.inMilliseconds <= 0) {
        whiteTime = Duration.zero;
        _handleTimeout(PlayerColor.white);
      }
    } else {
      blackTime = _blackTimeAtTurnStart! - elapsed;
      if (blackTime.inMilliseconds <= 0) {
        blackTime = Duration.zero;
        _handleTimeout(PlayerColor.black);
      }
    }

    if (state is! GameEnded) {
      // Only emit distinct seconds to avoid flooding the UI/Bloc stream
      // unless it's low time (< 10 sec) where we want smooth updates
      emit(_copyStateWithTime(state));
      // Periodic persist of time for crash recovery
      if (whiteTime.inSeconds % 5 == 0) _persist();
    }
  }

  // Called when user returns to app to force an immediate time sync
  void onResume() {
    _updateTime();
  }

  void onPause() {
    _persist();
  }

  void _handleTimeout(PlayerColor loser) {
    _timer?.cancel();
    _abandonTimer?.cancel();
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

  void _startAbandonTimer() {
    _abandonTimer?.cancel();
    _abandonTimer = Timer(_abandonTimeout, () {
      if (!_firstMoveMade) {
        _handleAbandonTimeout();
      }
    });
  }

  void _handleAbandonTimeout() {
    _timer?.cancel();
    AudioService().playGameOverSound();
    // No winner in abandoned game, or technically the one who didn't move loses?
    // Usually abandoned means aborted. Let's say no winner/aborted.
    emit(GameEnded(
      winner: null,
      reason: GameEndReason.abandoned,
      moveCount: 0,
      board: _chessBoard,
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
    if (!_firstMoveMade) {
      _firstMoveMade = true;
      _abandonTimer?.cancel();
    }

    // Apply time increment
    if (_chessBoard.currentTurn == PlayerColor.black) {
      // White just moved
      whiteTime += _timeIncrement;
    } else {
      // Black just moved
      blackTime += _timeIncrement;
    }

    if (CheckDetector.isCheckmate(_chessBoard, _chessBoard.currentTurn)) {
      _timer?.cancel();
      _abandonTimer?.cancel();
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
      _abandonTimer?.cancel();
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
      _persist();
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
