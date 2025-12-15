import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/utils/audio_service.dart';
import 'package:flutter_chess/utils/check_detector.dart';

class ChessCubit extends Cubit<ChessState> {
  final ChessBoard _chessBoard = ChessBoard();
  ChessPiece? selectedPiece;
  Position? selectedPosition;

  ChessCubit() : super(ChessInitial(board: ChessBoard())) {
    initializeBoard(); // Initialize board on creation
  }

  void initializeBoard() {
    _chessBoard.initializeBoard();
    emit(ChessInitial(board: _chessBoard));
    // Force a second emit to ensure listeners (like BoardComponent) catch it
    // BlocListenable only triggers on changes, not initial state
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(ChessInitial(board: _chessBoard));
    });
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

      _chessBoard.movePiece(from, to); // Make the move

      // Use CheckDetector for all rule validation to verify checkmate/check/stalemate correctly
      // This ensures consistent logic especially for pawn attacks
      if (CheckDetector.isCheckmate(_chessBoard, _chessBoard.currentTurn)) {
        AudioService().playGameOverSound();
        // Emit Checkmate state with winner
        emit(Checkmate(
          winner: _chessBoard.currentTurn == PlayerColor.white
              ? PlayerColor.black
              : PlayerColor.white,
          moveCount: _chessBoard.moveCount,
          board: _chessBoard,
          lastMoveFrom: from,
          lastMoveTo: to,
        ));
      } else if (CheckDetector.isKingInCheck(
          _chessBoard, _chessBoard.currentTurn)) {
        AudioService().playCheckSound();
        // Emit CheckState if king is in check
        emit(CheckState(
          colorInCheck: _chessBoard.currentTurn,
          board: _chessBoard,
          lastMoveFrom: from,
          lastMoveTo: to,
        ));
      } else if (CheckDetector.isStalemate(
          _chessBoard, _chessBoard.currentTurn)) {
        AudioService().playGameOverSound();
        // Emit Stalemate state
        emit(Stalemate(
          moveCount: _chessBoard.moveCount,
          board: _chessBoard,
          lastMoveFrom: from,
          lastMoveTo: to,
        ));
      } else {
        // Normal Move or Capture
        if (isCapture) {
          AudioService().playCaptureSound();
        } else {
          AudioService().playMoveSound();
        }

        // Emit MoveMade state
        emit(MoveMade(
          currentTurn: _chessBoard.currentTurn,
          board: _chessBoard,
          lastMoveFrom: from,
          lastMoveTo: to,
        ));
      }
    } catch (e) {
      // Emit ChessError state in case of exceptions
      emit(ChessError(
        message: e.toString(),
        board: _chessBoard,
        // Error state might want to preserve previous lastMove if available?
        // But Cubit doesn't store it separately from State.
        // Accessing state.lastMoveFrom isn't easy inside Cubit methods unless we check state.
        // For now, null is acceptable or we can try access current state.
        lastMoveFrom: state.lastMoveFrom,
        lastMoveTo: state.lastMoveTo,
      ));
    }
  }

  void resign() {
    // Current player resigns, opponent wins
    emit(Resignation(
      resignedPlayer: _chessBoard.currentTurn,
      moveCount: _chessBoard.moveCount,
      board: _chessBoard,
    ));
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
}
