// // lib/game/chess_board.dart

// import 'package:flutter_chess/game/pieces/bishop.dart';
// import 'package:flutter_chess/game/chess_piece_svg.dart';
// import 'package:flutter_chess/game/pieces/king.dart';
// import 'package:flutter_chess/game/pieces/knight.dart';
// import 'package:flutter_chess/game/pieces/pawn.dart';
// import 'package:flutter_chess/game/pieces/queen.dart';
// import 'package:flutter_chess/game/pieces/rook.dart';

// class ChessBoard {
//   List<List<ChessPieceSvg?>> board;

//   ChessBoard() : board = List.generate(8, (_) => List.generate(8, (_) => null));

//   // Place pieces on the board
//   void initializeBoard() {
//     // Place Black Pieces
//     board[0][0] = ChessPieceSvg(Rook(color: 'black', position: 'a1'));
//     board[0][1] = ChessPieceSvg(Knight(color: 'black', position: 'b1'));
//     board[0][2] = ChessPieceSvg(Bishop(color: 'black', position: 'c1'));
//     board[0][3] = ChessPieceSvg(Queen(color: 'black', position: 'd1'));
//     board[0][4] = ChessPieceSvg(King(color: 'black', position: 'e1'));
//     board[0][5] = ChessPieceSvg(Bishop(color: 'black', position: 'f1'));
//     board[0][6] = ChessPieceSvg(Knight(color: 'black', position: 'g1'));
//     board[0][7] = ChessPieceSvg(Rook(color: 'black', position: 'h1'));

//     // Place Black Pawns
//     for (int i = 0; i < 8; i++) {
//       board[1][i] = ChessPieceSvg(Pawn(color: 'black', position: '${String.fromCharCode(97 + i)}2'));
//     }

//     // Place White Pieces
//     board[7][0] = ChessPieceSvg(Rook(color: 'white', position: 'a8'));
//     board[7][1] = ChessPieceSvg(Knight(color: 'white', position: 'b8'));
//     board[7][2] = ChessPieceSvg(Bishop(color: 'white', position: 'c8'));
//     board[7][3] = ChessPieceSvg(Queen(color: 'white', position: 'd8'));
//     board[7][4] = ChessPieceSvg(King(color: 'white', position: 'e8'));
//     board[7][5] = ChessPieceSvg(Bishop(color: 'white', position: 'f8'));
//     board[7][6] = ChessPieceSvg(Knight(color: 'white', position: 'g8'));
//     board[7][7] = ChessPieceSvg(Rook(color: 'white', position: 'h8'));

//     // Place White Pawns
//     for (int i = 0; i < 8; i++) {
//       board[6][i] = ChessPieceSvg(Pawn(color: 'white', position: '${String.fromCharCode(97 + i)}7'));
//     }
//   }

//   // Update the position of a piece
//   void movePiece(String fromPosition, String toPosition) {
//     int fromCol = fromPosition.codeUnitAt(0) - 97;
//     int fromRow = int.parse(fromPosition[1]) - 1;
//     int toCol = toPosition.codeUnitAt(0) - 97;
//     int toRow = int.parse(toPosition[1]) - 1;

//     ChessPieceSvg? piece = board[fromRow][fromCol];
//     if (piece != null && piece.chessPiece.getValidMoves(fromPosition).contains(toPosition)) {
//       board[toRow][toCol] = piece;
//       board[fromRow][fromCol] = null;
//     }
//   }
// }



// lib/game/chess_board.dart

import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/bishop.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/pieces/knight.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/game/pieces/queen.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';

class ChessBoard {
  List<List<ChessPiece?>> board;

  List<int>columnPositions = [1,2,3,4,5,67,8];
  List<String> rowPositions = ['a','b','c','d','e','f','g','h'];

  ChessBoard() : board = List.generate(8, (_) => List.generate(8, (_) => null));

  void initializeBoard() {
    // Initialize Black Pieces (row 0 and 1)
    board[0][0] = Rook(PieceColor.black, Position(row: 0, col: 0)); // a1
    board[0][1] = Knight(PieceColor.black, Position(row: 0, col: 1)); // b1
    board[0][2] = Bishop(PieceColor.black, Position(row: 0, col: 2)); // c1
    board[0][3] = Queen(PieceColor.black, Position(row: 0, col: 3));  // d1
    board[0][4] = King(PieceColor.black, Position(row: 0, col: 4));   // e1
    board[0][5] = Bishop(PieceColor.black, Position(row: 0, col: 5)); // f1
    board[0][6] = Knight(PieceColor.black, Position(row: 0, col: 6)); // g1
    board[0][7] = Rook(PieceColor.black, Position(row: 0, col: 7));   // h1

    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(PieceColor.black, Position(row: 1, col: i)); // a2, b2, ..., h2
    }

    // Initialize White Pieces (row 6 and 7)
    board[7][0] = Rook(PieceColor.white, Position(row: 7, col: 0)); // a8
    board[7][1] = Knight(PieceColor.white, Position(row: 7, col: 1)); // b8
    board[7][2] = Bishop(PieceColor.white, Position(row: 7, col: 2)); // c8
    board[7][3] = Queen(PieceColor.white, Position(row: 7, col: 3));  // d8
    board[7][4] = King(PieceColor.white, Position(row: 7, col: 4));   // e8
    board[7][5] = Bishop(PieceColor.white, Position(row: 7, col: 5)); // f8
    board[7][6] = Knight(PieceColor.white, Position(row: 7, col: 6)); // g8
    board[7][7] = Rook(PieceColor.white, Position(row: 7, col: 7));   // h8

    for (int i = 0; i < 8; i++) {
      board[6][i] = Pawn(PieceColor.white, Position(row: 6, col: i)); // a7, b7, ..., h7
    }
  }

  // Move piece from one position to another
  void movePiece(String fromPosition, String toPosition) {
    // Convert positions to indices
    int fromCol = fromPosition.codeUnitAt(0) - 97;
    int fromRow = 8 - int.parse(fromPosition[1]);
    int toCol = toPosition.codeUnitAt(0) - 97;
    int toRow = 8 - int.parse(toPosition[1]);

    ChessPiece? piece = board[fromRow][fromCol];
    if (piece != null && piece.isValidMove(Position(row: toRow, col: toCol), this)) {
      board[toRow][toCol] = piece;
      board[fromRow][fromCol] = null;
    }
  }

   ChessPiece? getPiece(Position position) {
    return board[position.row][position.col];
  }

  bool isEmpty(Position position) {
    return board[position.row][position.col] == null;
  }
}

