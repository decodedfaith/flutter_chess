import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/bishop.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/pieces/knight.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/game/pieces/queen.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/models/captured_piece.dart';

class ChessBoard {
  late Map<String, Map<int, ChessPiece?>> board;
  late PlayerColor currentTurn;

  // Optimized capture storage using lightweight model
  List<CapturedPiece> capturedWhitePieces = [];
  List<CapturedPiece> capturedBlackPieces = [];

  // Chess columns and rows
  final List<int> rowPositions = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> columnPositions = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  ChessBoard() {
    // Initialize the board as a map of maps
    board = Map.fromEntries(
      columnPositions.map(
        (col) => MapEntry(
          col,
          Map.fromEntries(rowPositions.map((row) => MapEntry(row, null))),
        ),
      ),
    );
  }

  void initializeBoard() {
    currentTurn = PlayerColor.white;
    capturedWhitePieces.clear();
    capturedBlackPieces.clear();

    // Initialize Black Pieces (row 8 and 7)
    board['a']![8] = Rook(PlayerColor.black, Position(col: 'a', row: 8)); // a8
    board['b']![8] =
        Knight(PlayerColor.black, Position(col: 'b', row: 8)); // b8
    board['c']![8] =
        Bishop(PlayerColor.black, Position(col: 'c', row: 8)); // c8
    board['d']![8] = Queen(PlayerColor.black, Position(col: 'd', row: 8)); // d8
    board['e']![8] = King(PlayerColor.black, Position(col: 'e', row: 8)); // e8
    board['f']![8] =
        Bishop(PlayerColor.black, Position(col: 'f', row: 8)); // f8
    board['g']![8] =
        Knight(PlayerColor.black, Position(col: 'g', row: 8)); // g8
    board['h']![8] = Rook(PlayerColor.black, Position(col: 'h', row: 8)); // h8

    for (int i = 0; i < 8; i++) {
      board[columnPositions[i]]![7] = Pawn(PlayerColor.black,
          Position(col: columnPositions[i], row: 7)); // a7, b7, ..., h7
    }

    // Initialize White Pieces (row 1 and 2)
    board['a']![1] = Rook(PlayerColor.white, Position(col: 'a', row: 1)); // a1
    board['b']![1] =
        Knight(PlayerColor.white, Position(col: 'b', row: 1)); // b1
    board['c']![1] =
        Bishop(PlayerColor.white, Position(col: 'c', row: 1)); // c1
    board['d']![1] = Queen(PlayerColor.white, Position(col: 'd', row: 1)); // d1
    board['e']![1] = King(PlayerColor.white, Position(col: 'e', row: 1)); // e1
    board['f']![1] =
        Bishop(PlayerColor.white, Position(col: 'f', row: 1)); // f1
    board['g']![1] =
        Knight(PlayerColor.white, Position(col: 'g', row: 1)); // g1
    board['h']![1] = Rook(PlayerColor.white, Position(col: 'h', row: 1)); // h1

    for (int i = 0; i < 8; i++) {
      board[columnPositions[i]]![2] = Pawn(PlayerColor.white,
          Position(col: columnPositions[i], row: 2)); // a2, b2, ..., h2
    }
  }

  void movePiece(Position from, Position to) {
    try {
      // Retrieve the piece at the 'from' position
      ChessPiece? piece = board[from.col]![from.row];

      if (piece == null || piece.color != currentTurn) {
        throw Exception('Invalid move: no piece at source or wrong turn');
      }

      // Validate the move
      if (piece.isValidMove(to, this)) {
        // Check for capture - use lightweight model
        ChessPiece? targetPiece = board[to.col]![to.row];
        if (targetPiece != null) {
          final capturedPiece = CapturedPiece(
            type: targetPiece.type,
            color: targetPiece.color,
          );

          if (targetPiece.color == PlayerColor.white) {
            capturedWhitePieces.add(capturedPiece);
          } else {
            capturedBlackPieces.add(capturedPiece);
          }
        }

        // Perform the move
        board[to.col]![to.row] = piece;
        board[from.col]![from.row] = null;

        // Update the piece's position
        piece.position = to;

        // Pawn promotion: auto-promote to Queen when reaching end rank
        if (piece is Pawn) {
          if ((piece.color == PlayerColor.white && to.row == 8) ||
              (piece.color == PlayerColor.black && to.row == 1)) {
            board[to.col]![to.row] = Queen(piece.color, to, id: piece.id);
          }
        }

        // Switch turns
        currentTurn = currentTurn == PlayerColor.white
            ? PlayerColor.black
            : PlayerColor.white;
      } else {
        throw Exception('Invalid move for ${piece.runtimeType}');
      }
    } catch (e) {
      throw Exception('Error moving piece: ${e.toString()}');
    }
  }

  bool isCheckmate() {
    // Check if the current player's king has no valid moves and is under attack
    PlayerColor opponentColor = currentTurn == PlayerColor.white
        ? PlayerColor.black
        : PlayerColor.white;
    Position? kingPosition = findKing(currentTurn);
    if (kingPosition == null) return false;

    return isUnderAttack(kingPosition, opponentColor) &&
        noValidMoves(currentTurn);
  }

  bool isStalemate() {
    // Stalemate: Not in check, but no valid moves
    Position? kingPosition = findKing(currentTurn);
    if (kingPosition == null) return false;

    PlayerColor opponentColor = currentTurn == PlayerColor.white
        ? PlayerColor.black
        : PlayerColor.white;

    return !isUnderAttack(kingPosition, opponentColor) &&
        noValidMoves(currentTurn);
  }

  bool isInCheck() {
    // Check if the current player's king is under attack
    Position? kingPosition = findKing(currentTurn);
    if (kingPosition == null) return false;

    PlayerColor opponentColor = currentTurn == PlayerColor.white
        ? PlayerColor.black
        : PlayerColor.white;
    return isUnderAttack(kingPosition, opponentColor);
  }

  Position? findKing(PlayerColor playerColor) {
    // Iterate through all columns (a-h) and rows (1-8)
    for (String col in columnPositions) {
      for (int row in rowPositions) {
        ChessPiece? piece =
            board[col]![row]; // Access the piece at the current position
        if (piece is King && piece.color == playerColor) {
          return piece.position; // Return the position of the King
        }
      }
    }
    return null; // Return null if no King is found
  }

  bool isUnderAttack(Position position, PlayerColor opponentColor) {
    // Iterate through all columns (a-h) and rows (1-8)
    for (String col in columnPositions) {
      for (int row in rowPositions) {
        ChessPiece? piece =
            board[col]![row]; // Access the piece at the current position
        if (piece != null && piece.color == opponentColor) {
          // Check if the piece can attack the given position
          if (piece.isValidMove(position, this)) {
            return true;
          }
        }
      }
    }
    return false; // Return false if no piece can attack the position
  }

  bool noValidMoves(PlayerColor playerColor) {
    // Optimized: O(n²) instead of O(n⁴)
    // Only iterate pieces, use their pre-computed valid moves
    for (var col in columnPositions) {
      for (var row in rowPositions) {
        ChessPiece? piece = board[col]![row];

        if (piece != null && piece.color == playerColor) {
          // Use piece's getValidMoves (already filters out check-exposing moves)
          final validMoves = piece.getValidMoves(this);
          if (validMoves.isNotEmpty) {
            return false; // Found at least one valid move
          }
        }
      }
    }

    return true; // No valid moves found
  }

  ChessPiece? getPiece(Position position) {
    // Safely access the piece at the given position
    return board[position.col]?[position.row];
  }

  bool isEmpty(Position position) {
    // Check if the position is null (i.e., empty)
    return board[position.col]?[position.row] == null;
  }

  List<ChessPiece> getPiecesByColor(PlayerColor color) {
    List<ChessPiece> pieces = [];

    // Iterate through all columns (a-h)
    for (String col in columnPositions) {
      // Iterate through all rows (1-8)
      for (int row in rowPositions) {
        ChessPiece? piece = board[col]?[row];
        if (piece != null && piece.color == color) {
          pieces
              .add(piece); // Add the piece to the list if it matches the color
        }
      }
    }

    return pieces;
  }

  bool isValidMove(Position from, Position to, ChessPiece piece) {
    // Ensure move is within bounds
    if (to.row < 0 ||
        to.row >= 8 ||
        chessColToIndex(to.col) < 0 ||
        chessColToIndex(to.col) >= 8) {
      return false;
    }

    // Check if the move follows piece-specific rules
    if (!piece.isValidMove(to, this)) {
      return false;
    }

    // Prevent moves that would place the current player's king in check
    ChessBoard simulatedBoard = simulateMove(from, to);
    if (simulatedBoard.isKingInCheck(piece.color)) {
      return false;
    }

    return true;
  }

  ChessBoard simulateMove(Position from, Position to) {
    // Create a new ChessBoard instance to simulate the move
    ChessBoard simulatedBoard = ChessBoard();

    // Copy the current board state into the simulated board
    simulatedBoard.board = {
      for (var col in columnPositions)
        col: {
          for (var row in rowPositions)
            row: board[col]?[row]
                ?.copyWith(position: Position(col: col, row: row))
        }
    };

    // Get the piece at the `from` position
    ChessPiece? piece = simulatedBoard.getPiece(from);

    if (piece != null) {
      // Move the piece to the `to` position
      simulatedBoard.board[to.col]?[to.row] = piece.copyWith(position: to);
      // Remove the piece from the `from` position
      simulatedBoard.board[from.col]?[from.row] = null;
    }

    // Preserve the current turn in the simulated board
    simulatedBoard.currentTurn = currentTurn;

    return simulatedBoard;
  }

  bool isKingInCheck(PlayerColor playerColor) {
    Position? kingPosition = findKing(playerColor);
    if (kingPosition == null) return false;

    PlayerColor opponentColor = playerColor == PlayerColor.white
        ? PlayerColor.black
        : PlayerColor.white;
    for (var piece in getPiecesByColor(opponentColor)) {
      if (piece.getValidMoves(this).contains(kingPosition)) {
        return true;
      }
    }
    return false;
  }

  int chessColToIndex(String col) {
    // Convert chess column ('a'-'h') to array index (0-7)
    return col.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  String indexToChessCol(int colIndex) {
    // Convert array index (0-7) to chess column ('a'-'h')
    return String.fromCharCode('a'.codeUnitAt(0) + colIndex);
  }
}
