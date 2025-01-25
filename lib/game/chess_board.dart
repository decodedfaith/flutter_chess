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

  List<int> rowPositions = [1,2,3,4,5,6,7,8];
  List<String> columnPositions = ['a','b','c','d','e','f','g','h'];
  late PlayerColor currentTurn;

  ChessBoard() : board = List.generate(8, (index) => List.generate(8, (_) => null));

  void initializeBoard() {
    currentTurn = PlayerColor.white; // Set currentTurn during board initialization
    // Initialize Black Pieces (row 7 and 6)
    board[7][0] = Rook(PlayerColor.black, Position(col: 'a', row: 8)); // a8
    board[7][1] = Knight(PlayerColor.black, Position(col: 'b', row: 8,)); // b8
    board[7][2] = Bishop(PlayerColor.black, Position(col: 'c', row: 8)); // c8
    board[7][3] = Queen(PlayerColor.black, Position(col: 'd', row: 8));  // d8
    board[7][4] = King(PlayerColor.black, Position(col: 'e', row: 8));   // e8
    board[7][5] = Bishop(PlayerColor.black, Position(col: 'f', row: 8)); // f8
    board[7][6] = Knight(PlayerColor.black, Position(col: 'g', row: 8)); // g8
    board[7][7] = Rook(PlayerColor.black, Position(col: 'h', row: 8));   // h8

    for (int i = 0; i < 8; i++) {
      board[6][i] = Pawn(PlayerColor.black, Position(col: columnPositions[i], row: 7)); // a7, b7, ..., h7
    }

    // Initialize White Pieces (row 1 and 2)
    board[0][0] = Rook(PlayerColor.white, Position(col: 'a', row: 1)); // a1
    board[0][1] = Knight(PlayerColor.white, Position(col: 'b', row: 1)); // b1
    board[0][2] = Bishop(PlayerColor.white, Position(col: 'c', row: 1)); // c1
    board[0][3] = Queen(PlayerColor.white, Position(col: 'd', row: 1));  // d1
    board[0][4] = King(PlayerColor.white, Position(col: 'e', row: 1));   // e1
    board[0][5] = Bishop(PlayerColor.white, Position(col: 'f', row: 1)); // f1
    board[0][6] = Knight(PlayerColor.white, Position(col: 'g', row: 1)); // g1
    board[0][7] = Rook(PlayerColor.white, Position(col: 'h', row: 1));   // h1

    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(PlayerColor.white, Position(col: columnPositions[i], row: 2)); // a2, b2, ..., h2
    }
  }

  void movePiece(Position from, Position to) {
    try {
      // Retrieve the piece at the 'from' position
      ChessPiece? piece = board[from.row][chessColToIndex(from.col)];
      
      if (piece == null || piece.color != currentTurn) {
        throw Exception('Invalid move: no piece at source or wrong turn');
      }

      // Validate the move
      if (piece.isValidMove(to, this)) {
        // Perform the move
        board[to.row][chessColToIndex(to.col)] = piece;
        board[from.row][chessColToIndex(from.col)] = null;
        
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
              if (piece.isValidMove(Position(row: targetRow, col: indexToChessCol(targetCol)), this)) {
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
    return board[position.row][chessColToIndex(position.col)];
  }

  bool isEmpty(Position position) {
    return board[position.row][chessColToIndex(position.col)] == null;
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
    if (to.row < 0 || to.row >= 8 || chessColToIndex(to.col) < 0 || chessColToIndex(to.col) >= 8) {
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
        (col) => board[row][col]?.copyWith(position: Position(row: row, col: indexToChessCol(col))),
      ),
    );

    ChessPiece? piece = simulatedBoard.getPiece(from);
    if (piece != null) {
      simulatedBoard.board[to.row][chessColToIndex(to.col)] = piece.copyWith(position: to);
      simulatedBoard.board[from.row][chessColToIndex(from.col)] = null;
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
            Position from = Position(row: row, col: indexToChessCol(col));
            Position to = Position(row: targetRow, col: indexToChessCol(targetCol));

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

  int chessColToIndex(String col) {
    // Convert chess column ('a'-'h') to array index (0-7)
    return col.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  String indexToChessCol(int colIndex) {
    // Convert array index (0-7) to chess column ('a'-'h')
    return String.fromCharCode('a'.codeUnitAt(0) + colIndex);
  }

}

