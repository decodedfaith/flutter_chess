// // lib/game/chess_piece.dart

// abstract class ChessPiece {
//   final String type;
//   final String color;  // "black" or "white"
//   final String position; // Position on the board (e.g., "a1", "h8")

//   ChessPiece({required this.type, required this.color, required this.position});

//   // Abstract method to get valid moves for a piece
//   List<String> getValidMoves(String position);
// }

// class Pawn extends ChessPiece {
//   Pawn({required String color, required String position})
//       : super(type: "pawn", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     // Basic logic for pawn movement (can be expanded for captures, en passant)
//     List<String> moves = [];
//     if (color == "white") {
//       moves.add(position.substring(0, 1) + (int.parse(position.substring(1)) + 1).toString());
//     } else if (color == "black") {
//       moves.add(position.substring(0, 1) + (int.parse(position.substring(1)) - 1).toString());
//     }
//     return moves;
//   }
// }

// class Rook extends ChessPiece {
//   Rook({required String color, required String position})
//       : super(type: "rook", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     List<String> moves = [];
//     // Rook can move horizontally or vertically
//     var col = position.substring(0, 1); // Extract column (a-h)
//     var row = int.parse(position.substring(1)); // Extract row (1-8)

//     // Horizontal and vertical moves can be generated here
//     for (int i = 1; i <= 8; i++) {
//       moves.add(col + i.toString());
//     }
//     for (int i = 1; i <= 8; i++) {
//       moves.add(String.fromCharCode(96 + i) + row.toString());
//     }
//     return moves;
//   }
// }

// class Knight extends ChessPiece {
//   Knight({required String color, required String position})
//       : super(type: "knight", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     List<String> moves = [];
//     int col = position.codeUnitAt(0) - 96; // Convert column to number (a=1, b=2, etc.)
//     int row = int.parse(position.substring(1));

//     // Knight's L-shaped moves
//     List<List<int>> moveOffsets = [
//       [2, 1], [2, -1], [-2, 1], [-2, -1],
//       [1, 2], [1, -2], [-1, 2], [-1, -2]
//     ];

//     for (var offset in moveOffsets) {
//       int newCol = col + offset[0];
//       int newRow = row + offset[1];

//       if (newCol >= 1 && newCol <= 8 && newRow >= 1 && newRow <= 8) {
//         moves.add(String.fromCharCode(96 + newCol) + newRow.toString());
//       }
//     }
//     return moves;
//   }
// }

// class Bishop extends ChessPiece {
//   Bishop({required String color, required String position})
//       : super(type: "bishop", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     List<String> moves = [];
//     // Bishops move diagonally, so we calculate all possible diagonal moves here
//     var col = position.substring(0, 1); // Extract column (a-h)
//     var row = int.parse(position.substring(1)); // Extract row (1-8)
//     return moves; // Diagonal logic can be implemented
//   }
// }

// class Queen extends ChessPiece {
//   Queen({required String color, required String position})
//       : super(type: "queen", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     // Queen combines the movement rules of rook and bishop
//     List<String> moves = [];
//     moves.addAll(Rook(color: color, position: position).getValidMoves(position));
//     moves.addAll(Bishop(color: color, position: position).getValidMoves(position));
//     return moves;
//   }
// }

// class King extends ChessPiece {
//   King({required String color, required String position})
//       : super(type: "king", color: color, position: position);

//   @override
//   List<String> getValidMoves(String position) {
//     List<String> moves = [];
//     // King can move one square in any direction
//     var col = position.substring(0, 1); // Extract column (a-h)
//     var row = int.parse(position.substring(1)); // Extract row (1-8)
//     return moves; // Movement can be calculated here
//   }
// }


// // lib/game/chess_piece.dart
// class ChessPiece {
//   final String type;  // E.g., "king", "queen", etc.
//   final String color; // "white" or "black"

//   ChessPiece({required this.type, required this.color});

//   // Abstract method for getting valid moves for the piece
//   List<String> getValidMoves(String position) {
//     return [];
//   }
// }


// chess_piece.dart
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/position.dart';

enum PieceColor {
  white,
  black;

  // Method to return the enum name as a string
  String get name => toString().split('.').last;
}

abstract class ChessPiece {
  final PieceColor color;
  final String type;

  ChessPiece(this.color, this.type);

  // Abstract method to get SVG asset path
  String getSvgAssetPath();

  // bool isValidMove(Position nwPosition, ChessBoard board);
}
