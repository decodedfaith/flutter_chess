import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';

class GameController {
  final ChessBoard chessBoard;
  String currentPlayer = "White"; // White starts the game
  bool isGameOver = false;
  String? winner;

  GameController({required this.chessBoard});

  /// Switch the current player
  void switchPlayer() {
    currentPlayer = currentPlayer == "White" ? "Black" : "White";
  }

  /// Validate and perform a move
  String makeMove(Position from, Position to) {
    if (isGameOver) return "Game over! Winner: $winner";

    ChessPiece? piece = chessBoard.getPieceAt(from);
    if (piece == null) {
      return "No piece at the selected position.";
    }

    if (piece.color != currentPlayer) {
      return "It's $currentPlayer's turn.";
    }

    if (!piece.isValidMove(to, chessBoard)) {
      return "Invalid move for ${piece.type}.";
    }

    // Perform the move
    chessBoard.movePiece(from as String, to as String);

    // Check for special game states (check, checkmate, stalemate)
    if (isKingInCheck(currentPlayer)) {
      if (isCheckmate(currentPlayer)) {
        isGameOver = true;
        winner = currentPlayer == "White" ? "Black" : "White";
        return "Checkmate! $winner wins!";
      } else {
        return "Check!";
      }
    } else if (isStalemate()) {
      isGameOver = true;
      return "Stalemate! It's a draw.";
    }

    // Switch turn after a valid move
    switchPlayer();
    return "Move successful.";
  }

  /// Check if the king of the given player is in check
  bool isKingInCheck(String playerColor) {
    Position? kingPosition = chessBoard.findKing(playerColor);
    if (kingPosition == null) return false;

    return chessBoard.isUnderAttack(kingPosition, opponentColor(playerColor));
  }

  /// Check if the given player is in checkmate
  bool isCheckmate(String playerColor) {
    if (!isKingInCheck(playerColor)) return false;

    // Iterate through all pieces of the player
    for (var piece in chessBoard.getPiecesByColor(playerColor)) {
      for (var move in piece.getValidMoves(chessBoard)) {
        ChessBoard simulatedBoard = chessBoard.simulateMove(piece.position, move);
        if (!simulatedBoard.isKingInCheck(playerColor)) {
          return false; // If there's a valid move to escape check, not a checkmate
        }
      }
    }
    return true;
  }

  /// Check if the game is in a stalemate
  bool isStalemate() {
    for (var color in ["White", "Black"]) {
      for (var piece in chessBoard.getPiecesByColor(color)) {
        if (piece.getValidMoves(chessBoard).isNotEmpty) {
          return false; // At least one valid move exists, not stalemate
        }
      }
    }
    return true;
  }

  /// Get the opponent's color
  String opponentColor(String color) {
    return color == "White" ? "Black" : "White";
  }
}
