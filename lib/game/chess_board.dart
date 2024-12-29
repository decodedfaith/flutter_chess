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

class ChessBoard {
  List<List<ChessPiece?>> board;

  List<int>columnPositions = [1,2,3,4,5,67,8];
  List<String> rowPositions = ['a','b','c','d','e','f','g','h'];

  ChessBoard() : board = List.generate(8, (_) => List.generate(8, (_) => null));

  // Initialize the chessboard with the starting positions
  void initializeBoard() {
    // Black pieces
    board[0][0] = Rook(PieceColor.black);
    board[0][1] = Knight(PieceColor.black);
    board[0][2] = Bishop(PieceColor.black);
    board[0][3] = Queen(PieceColor.black);
    board[0][4] = King(PieceColor.black);
    board[0][5] = Bishop(PieceColor.black);
    board[0][6] = Knight(PieceColor.black);
    board[0][7] = Rook(PieceColor.black);
    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(PieceColor.black);
    }

    // White pieces
    board[7][0] = Rook(PieceColor.black);
    board[7][1] = Knight(PieceColor.white);
    board[7][2] = Bishop(PieceColor.white);
    board[7][3] = Queen(PieceColor.white);
    board[7][4] = King(PieceColor.white);
    board[7][5] = Bishop(PieceColor.white);
    board[7][6] = Knight(PieceColor.white);
    board[7][7] = Rook(PieceColor.white);
    for (int i = 0; i < 8; i++) {
      board[6][i] = Pawn(PieceColor.white);
    }
  }

  // Move piece from one position to another
  void movePiece(String fromPosition, String toPosition) {
    // Convert positions to indices
    int fromCol = fromPosition.codeUnitAt(0) - 97;
    int fromRow = int.parse(fromPosition[1]) - 1;
    int toCol = toPosition.codeUnitAt(0) - 97;
    int toRow = int.parse(toPosition[1]) - 1;

    ChessPiece? piece = board[fromRow][fromCol];
    if (piece != null) {
      board[toRow][toCol] = piece;
      board[fromRow][fromCol] = null;
    }
  }
}

