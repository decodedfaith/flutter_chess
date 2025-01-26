import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class ChessCubit extends Cubit<ChessState> {
  final ChessBoard _chessBoard = ChessBoard();
  ChessPiece? selectedPiece;
  Position? selectedPosition;


  ChessCubit() : super(ChessInitial(ChessBoard())) {
    initializeBoard(); // Initialize board on creation
  }

  void initializeBoard() {
    _chessBoard.initializeBoard();
    emit(ChessInitial(_chessBoard));
  }

  void makeMove(Position from, Position to) {
    try {
      _chessBoard.movePiece(from, to); // Make the move

      print("Hello world");
      print(from);
      print(to);

      if (_chessBoard.isCheckmate()) {
        // Emit Checkmate state with winner
        emit(Checkmate(
          _chessBoard.currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white,
          _chessBoard,
        ));
      } else if (_chessBoard.isKingInCheck(_chessBoard.currentTurn)) {
        // Emit CheckState if king is in check
        emit(CheckState(
          _chessBoard.currentTurn,
          _chessBoard,
        ));
      } else if (_chessBoard.isStalemate()) {
        // Emit Stalemate state
        emit(Stalemate(_chessBoard));
      } else {
        // Emit MoveMade state
        emit(MoveMade(
          _chessBoard.currentTurn,
          _chessBoard,
        ));
      }
    } catch (e) {
      // Emit ChessError state in case of exceptions
      print(e);
      emit(ChessError(e.toString(), _chessBoard));
    }
  }

  void selectPiece(Position position) {
    // Logic to select the piece and highlight valid moves
    ChessPiece? piece = _chessBoard.getPiece(position);
    if (piece != null) {
      selectedPiece = piece;
      selectedPosition = position;

      // Emit state with the updated board and piece selection
      emit(MoveMade(_chessBoard.currentTurn, _chessBoard));
    }
  }



  void resetGame() {
    initializeBoard(); // Reinitialize board
  }
}
