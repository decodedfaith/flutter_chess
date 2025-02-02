import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class MoveValidator {
  final ChessBoard chessBoard;

  MoveValidator({required this.chessBoard});

  bool isValidMove(Position from, Position to, PlayerColor player) {
    ChessPiece? piece = chessBoard.getPiece(from);
    if (piece == null || piece.color != player) return false;

    if (!piece.isValidMove(to, chessBoard)) return false;

    // Simulate move to check if the king is left in check
    var simulatedBoard = chessBoard.simulateMove(from, to);
    if (simulatedBoard.isKingInCheck(player)) return false;

    return true;
  }
}
