import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/bishop.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/pieces/knight.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/game/pieces/queen.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class ChessBoard {
  List<List<ChessPiece?>> board;

  List<int>columnPositions = [1,2,3,4,5,67,8];
  List<String> rowPositions = ['a','b','c','d','e','f','g','h'];
  late PlayerColor currentTurn;

  ChessBoard() : board = List.generate(8, (_) => List.generate(8, (_) => null));

  void initializeBoard() {
    currentTurn = PlayerColor.white; // Set currentTurn during board initialization
    // Initialize Black Pieces (row 0 and 1)
    board[0][0] = Rook(PlayerColor.black, Position(row: 0, col: 0)); // a1
    board[0][1] = Knight(PlayerColor.black, Position(row: 0, col: 1)); // b1
    board[0][2] = Bishop(PlayerColor.black, Position(row: 0, col: 2)); // c1
    board[0][3] = Queen(PlayerColor.black, Position(row: 0, col: 3));  // d1
    board[0][4] = King(PlayerColor.black, Position(row: 0, col: 4));   // e1
    board[0][5] = Bishop(PlayerColor.black, Position(row: 0, col: 5)); // f1
    board[0][6] = Knight(PlayerColor.black, Position(row: 0, col: 6)); // g1
    board[0][7] = Rook(PlayerColor.black, Position(row: 0, col: 7));   // h1

    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(PlayerColor.black, Position(row: 1, col: i)); // a2, b2, ..., h2
    }

    // Initialize White Pieces (row 6 and 7)
    board[7][0] = Rook(PlayerColor.white, Position(row: 7, col: 0)); // a8
    board[7][1] = Knight(PlayerColor.white, Position(row: 7, col: 1)); // b8
    board[7][2] = Bishop(PlayerColor.white, Position(row: 7, col: 2)); // c8
    board[7][3] = Queen(PlayerColor.white, Position(row: 7, col: 3));  // d8
    board[7][4] = King(PlayerColor.white, Position(row: 7, col: 4));   // e8
    board[7][5] = Bishop(PlayerColor.white, Position(row: 7, col: 5)); // f8
    board[7][6] = Knight(PlayerColor.white, Position(row: 7, col: 6)); // g8
    board[7][7] = Rook(PlayerColor.white, Position(row: 7, col: 7));   // h8

    for (int i = 0; i < 8; i++) {
      board[6][i] = Pawn(PlayerColor.white, Position(row: 6, col: i)); // a7, b7, ..., h7
    }
  }

  void movePiece(Position from, Position to) {
    try {
      // Retrieve the piece at the 'from' position
      ChessPiece? piece = board[from.row][from.col];
      
      if (piece == null || piece.color != currentTurn) {
        throw Exception('Invalid move: no piece at source or wrong turn');
      }

      // Validate the move
      if (piece.isValidMove(to, this)) {
        // Perform the move
        board[to.row][to.col] = piece;
        board[from.row][from.col] = null;
        
        // Update the piece's position
        piece.position = to;
        
        // Switch turns
        currentTurn = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
      } else {
        throw Exception('Invalid move for ${piece.runtimeType}');
      }
    } catch (e) {
      throw Exception('Error moving piece: ${e.toString()}');
    }
  }


  bool isCheckmate() {
    // Check if the current player's king has no valid moves and is under attack
    PlayerColor opponentColor = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
    Position? kingPosition = findKing(currentTurn);
    if (kingPosition == null) return false;

    return isUnderAttack(kingPosition, opponentColor) && noValidMoves(currentTurn);
  }

  bool isInCheck() {
    // Check if the current player's king is under attack
    Position? kingPosition = findKing(currentTurn);
    if (kingPosition == null) return false;

    PlayerColor opponentColor = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
    return isUnderAttack(kingPosition, opponentColor);
  }

  Position? findKing(PlayerColor playerColor) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece is King && piece.color == playerColor) {
          return piece.position;
        }
      }
    }
    return null;
  }

  bool isUnderAttack(Position position, PlayerColor opponentColor) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.color == opponentColor && piece.isValidMove(position, this)) {
          return true;
        }
      }
    }
    return false;
  }

  bool noValidMoves(PlayerColor playerColor) {
    // Iterate through all pieces of the current player and check for valid moves
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.color == playerColor) {
          for (int targetRow = 0; targetRow < 8; targetRow++) {
            for (int targetCol = 0; targetCol < 8; targetCol++) {
              if (piece.isValidMove(Position(row: targetRow, col: targetCol), this)) {
                return false;
              }
            }
          }
        }
      }
    }
    return true;
  }

  ChessPiece? getPiece(Position position) {
    return board[position.row][position.col];
  }

  bool isEmpty(Position position) {
    return board[position.row][position.col] == null;
  }

   List<ChessPiece> getPiecesByColor(PlayerColor color) {
    List<ChessPiece> pieces = [];
    for (var row in board) {
      for (var piece in row) {
        if (piece != null && piece.color == color) {
          pieces.add(piece);
        }
      }
    }
    return pieces;
  }

  bool isValidMove(Position from, Position to, ChessPiece piece) {
    // Ensure move is within bounds
    if (to.row < 0 || to.row >= 8 || to.col < 0 || to.col >= 8) {
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
    ChessBoard simulatedBoard = ChessBoard();
    simulatedBoard.board = List.generate(
      8,
      (row) => List.generate(
        8,
        (col) => board[row][col]?.copyWith(position: Position(row: row, col: col)),
      ),
    );

    ChessPiece? piece = simulatedBoard.getPiece(from);
    if (piece != null) {
      simulatedBoard.board[to.row][to.col] = piece.copyWith(position: to);
      simulatedBoard.board[from.row][from.col] = null;
    }

    simulatedBoard.currentTurn = currentTurn; // Preserve the turn
    return simulatedBoard;
  }

  bool isKingInCheck(PlayerColor color) {
    Position? kingPosition = findKing(color);
    if (kingPosition == null) {
      throw Exception("King not found for color $color");
    }

    PlayerColor opponentColor = color == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
    for (var piece in getPiecesByColor(opponentColor)) {
      if (piece.getValidMoves(this).contains(kingPosition)) {
        return true;
      }
    }
    return false;
  }

  bool isStalemate() {
    // Step 1: Check if the current player's king is in check
    if (isInCheck()) {
      return false; // If in check, it cannot be a stalemate
    }

    // Step 2: Check if the current player has any legal moves
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];

        // Skip empty squares and opponent's pieces
        if (piece == null || piece.color != currentTurn) {
          continue;
        }

        // Iterate over all possible target squares
        for (int targetRow = 0; targetRow < 8; targetRow++) {
          for (int targetCol = 0; targetCol < 8; targetCol++) {
            Position from = Position(row: row, col: col);
            Position to = Position(row: targetRow, col: targetCol);

            // Check if the move is valid
            if (isValidMove(from, to, piece)) {
              return false; // A legal move exists, so not a stalemate
            }
          }
        }
      }
    }

    // If no legal moves are found and the player is not in check, it's a stalemate
    return true;
  }


}

