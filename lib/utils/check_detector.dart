import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

/// Utility class for check detection and validation
class CheckDetector {
  /// Check if a king at the given position is under attack
  static bool isKingInCheck(ChessBoard board, PlayerColor kingColor) {
    // Find the king
    Position? kingPosition = _findKing(board, kingColor);
    if (kingPosition == null) return false;

    // Check if any opponent piece can attack the king
    return isSquareUnderAttack(board, kingPosition, kingColor);
  }

  /// Check if a square is under attack by the opponent
  static bool isSquareUnderAttack(
      ChessBoard board, Position square, PlayerColor defenderColor) {
    final opponentColor = defenderColor == PlayerColor.white
        ? PlayerColor.black
        : PlayerColor.white;

    // Check all opponent pieces to see if they can attack this square
    for (var col in board.columnPositions) {
      for (var row in board.rowPositions) {
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == opponentColor) {
          // Check if this opponent piece can move to the square
          if (piece.isValidMove(square, board)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Find the king of the given color
  static Position? _findKing(ChessBoard board, PlayerColor color) {
    for (var col in board.columnPositions) {
      for (var row in board.rowPositions) {
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece is King && piece.color == color) {
          return position;
        }
      }
    }
    return null;
  }

  /// Check if a move would leave the king in check (illegal move)
  static bool wouldLeaveKingInCheck(
    ChessBoard board,
    Position from,
    Position to,
    PlayerColor playerColor,
  ) {
    // Simulate the move
    final originalPiece = board.getPiece(from);
    final capturedPiece = board.getPiece(to);

    if (originalPiece == null) return true;

    // Make temporary move
    board.board[to.col]![to.row] = originalPiece;
    board.board[from.col]![from.row] = null;
    originalPiece.position = to;

    // Check if king is in check after this move
    final inCheck = isKingInCheck(board, playerColor);

    // Undo the move
    board.board[from.col]![from.row] = originalPiece;
    board.board[to.col]![to.row] = capturedPiece;
    originalPiece.position = from;

    return inCheck;
  }

  /// Get all legal moves for a piece (moves that don't leave king in check)
  static List<Position> getLegalMoves(
    ChessBoard board,
    ChessPiece piece,
    Position from,
  ) {
    final validMoves = piece.getValidMoves(board);
    final legalMoves = <Position>[];

    for (final move in validMoves) {
      if (!wouldLeaveKingInCheck(board, from, move, piece.color)) {
        legalMoves.add(move);
      }
    }

    return legalMoves;
  }

  /// Check if it's checkmate
  static bool isCheckmate(ChessBoard board, PlayerColor color) {
    // Must be in check first
    if (!isKingInCheck(board, color)) return false;

    // Check if any piece has legal moves
    for (var col in board.columnPositions) {
      for (var row in board.rowPositions) {
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == color) {
          final legalMoves = getLegalMoves(board, piece, position);
          if (legalMoves.isNotEmpty) {
            return false; // Found a legal move, not checkmate
          }
        }
      }
    }

    return true; // No legal moves, it's checkmate
  }

  /// Check if it's stalemate
  static bool isStalemate(ChessBoard board, PlayerColor color) {
    // Must NOT be in check
    if (isKingInCheck(board, color)) return false;

    // Check if any piece has legal moves
    for (var col in board.columnPositions) {
      for (var row in board.rowPositions) {
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == color) {
          final legalMoves = getLegalMoves(board, piece, position);
          if (legalMoves.isNotEmpty) {
            return false; // Found a legal move, not stalemate
          }
        }
      }
    }

    return true; // No legal moves and not in check = stalemate
  }
}
