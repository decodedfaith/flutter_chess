import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';


class GameController {
  final ChessBoard chessBoard;
  PlayerColor currentPlayer = PlayerColor.white;
  bool isGameOver = false;
  PlayerColor? winner;

  GameController({required this.chessBoard});

  void switchPlayer() {
    currentPlayer = currentPlayer == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
  }

  String makeMove(Position from, Position to) {
    if (isGameOver) return "Game over! Winner: ${winner?.name}";

    ChessPiece? piece = chessBoard.getPiece(from);
    if (piece == null) return "No piece at the selected position.";
    if (piece.color != currentPlayer) return "It's ${currentPlayer.name}'s turn.";

    if (!piece.isValidMove(to, chessBoard)) return "Invalid move for ${piece.runtimeType}.";

    chessBoard.movePiece(from, to);

    if (isKingInCheck(currentPlayer)) {
      if (isCheckmate(currentPlayer)) {
        isGameOver = true;
        winner = currentPlayer == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
        return "Checkmate! ${winner?.name} wins!";
      }
      return "Check!";
    } else if (isStalemate()) {
      isGameOver = true;
      return "Stalemate! It's a draw.";
    }

    switchPlayer();
    return "Move successful.";
  }

  bool isKingInCheck(PlayerColor color) {
    Position? kingPosition = chessBoard.findKing(color);
    return kingPosition != null && chessBoard.isUnderAttack(kingPosition, opponentColor(color));
  }

  bool isCheckmate(PlayerColor color) {
    if (!isKingInCheck(color)) return false;

    for (var piece in chessBoard.getPiecesByColor(color)) {
      for (var move in piece.getValidMoves(chessBoard)) {
        var simulatedBoard = chessBoard.simulateMove(piece.position, move);
        if (!simulatedBoard.isKingInCheck(color)) return false;
      }
    }
    return true;
  }

  bool isStalemate() {
    for (var color in PlayerColor.values) {
      for (var piece in chessBoard.getPiecesByColor(color)) {
        if (piece.getValidMoves(chessBoard).isNotEmpty) return false;
      }
    }
    return true;
  }

  PlayerColor opponentColor(PlayerColor color) {
    return color == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
  }
}
