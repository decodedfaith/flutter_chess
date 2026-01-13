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
import 'package:flutter_chess/models/chess_move.dart';

class ChessBoard {
  late Map<String, Map<int, ChessPiece?>> board;
  late PlayerColor currentTurn;

  // Optimized capture storage using lightweight model
  List<CapturedPiece> capturedWhitePieces = [];
  List<CapturedPiece> capturedBlackPieces = [];

  // Chess columns and rows
  final List<int> rowPositions = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> columnPositions = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  // Game statistics
  int moveCount = 0;

  // Move history for review and analysis
  List<ChessMove> moveHistory = [];

  // En passant tracking
  Position? enPassantTarget;

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

  void movePiece(Position from, Position to, {String? promotionPieceType}) {
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

        // Handle en passant capture
        if (piece is Pawn && to == enPassantTarget) {
          // The captured pawn is on the SAME ROW as the attacking pawn (from.row)
          // not on the target square row
          // Example: Black a4 captures white b4 by moving to b3
          // Captured pawn is on b4 (same row as a4)
          ChessPiece? capturedPawn = board[to.col]![from.row];
          if (capturedPawn != null) {
            final captured = CapturedPiece(
              type: capturedPawn.type,
              color: capturedPawn.color,
            );
            if (capturedPawn.color == PlayerColor.white) {
              capturedWhitePieces.add(captured);
            } else {
              capturedBlackPieces.add(captured);
            }
            board[to.col]![from.row] =
                null; // Remove captured pawn from original row
          }
        }

        // Handle castling
        if (piece is King && (to.col == 'g' || to.col == 'c')) {
          int rowDir = piece.color == PlayerColor.white ? 1 : 8;
          // Kingside castling (King moves to g-file)
          if (to.col == 'g' && to.row == rowDir) {
            // Move rook from h to f
            ChessPiece? rook = board['h']![rowDir];
            if (rook != null) {
              board['f']![rowDir] =
                  rook.copyWith(position: Position(col: 'f', row: rowDir));
              board['h']![rowDir] = null;
            }
          }
          // Queenside castling (King moves to c-file)
          else if (to.col == 'c' && to.row == rowDir) {
            // Move rook from a to d
            ChessPiece? rook = board['a']![rowDir];
            if (rook != null) {
              board['d']![rowDir] =
                  rook.copyWith(position: Position(col: 'd', row: rowDir));
              board['a']![rowDir] = null;
            }
          }
        }

        // Mark King/Rook as moved
        if (piece is King || piece is Rook) {
          board[to.col]![to.row] = piece.copyWith(position: to, hasMoved: true);
        }

        if (piece is Pawn) {
          if ((piece.color == PlayerColor.white && to.row == 8) ||
              (piece.color == PlayerColor.black && to.row == 1)) {
            // Use provided promotion type or default to Queen if not specified (for tests/legacy)
            if (promotionPieceType == 'rook') {
              board[to.col]![to.row] = Rook(piece.color, to, id: piece.id);
            } else if (promotionPieceType == 'knight') {
              board[to.col]![to.row] = Knight(piece.color, to, id: piece.id);
            } else if (promotionPieceType == 'bishop') {
              board[to.col]![to.row] = Bishop(piece.color, to, id: piece.id);
            } else {
              board[to.col]![to.row] = Queen(piece.color, to, id: piece.id);
            }
          }

          // Set en passant target after 2-square pawn move
          // Target is the SKIPPED square, not the destination
          if ((piece.color == PlayerColor.white &&
                  from.row == 2 &&
                  to.row == 4) ||
              (piece.color == PlayerColor.black &&
                  from.row == 7 &&
                  to.row == 5)) {
            // Set target to the square the pawn passed through
            int targetRow = piece.color == PlayerColor.white ? 3 : 6;
            enPassantTarget = Position(col: to.col, row: targetRow);
          } else {
            enPassantTarget = null; // Reset for non-2-square pawn moves
          }
        } else {
          enPassantTarget = null; // Reset for any non-pawn move
        }

        // Switch turns
        currentTurn = currentTurn == PlayerColor.white
            ? PlayerColor.black
            : PlayerColor.white;

        // Record Move in History
        moveHistory.add(ChessMove(
          from: from,
          to: to,
          pieceType: piece.type,
          color: piece.color,
          isCapture:
              targetPiece != null || (piece is Pawn && to == enPassantTarget),
          promotionType: promotionPieceType,
          timestamp: DateTime.now(),
        ));

        // Increment move counter
        moveCount++;
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
    if (to.row < 1 ||
        to.row > 8 ||
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
