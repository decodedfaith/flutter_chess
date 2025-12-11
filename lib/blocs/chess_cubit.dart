import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
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
      _chessBoard.movePiece(from, to); // Make the move

      // Use CheckDetector for all rule validation to verify checkmate/check/stalemate correctly
      // This ensures consistent logic especially for pawn attacks
      if (CheckDetector.isCheckmate(_chessBoard, _chessBoard.currentTurn)) {
        // Emit Checkmate state with winner
        emit(Checkmate(
          winner: _chessBoard.currentTurn == PlayerColor.white
              ? PlayerColor.black
              : PlayerColor.white,
          moveCount: _chessBoard.moveCount,
          board: _chessBoard,
        ));
      } else if (CheckDetector.isKingInCheck(
          _chessBoard, _chessBoard.currentTurn)) {
        // Emit CheckState if king is in check
        emit(CheckState(
          colorInCheck: _chessBoard.currentTurn,
          board: _chessBoard,
        ));
      } else if (CheckDetector.isStalemate(
          _chessBoard, _chessBoard.currentTurn)) {
        // Emit Stalemate state
        emit(Stalemate(
          moveCount: _chessBoard.moveCount,
          board: _chessBoard,
        ));
      } else {
        // Emit MoveMade state
        emit(MoveMade(
          currentTurn: _chessBoard.currentTurn,
          board: _chessBoard,
        ));
      }
    } catch (e) {
      // Emit ChessError state in case of exceptions
      emit(ChessError(
        message: e.toString(),
        board: _chessBoard,
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
      ));
    }
  }

  void resetGame() {
    initializeBoard(); // Reinitialize board
  }
}
