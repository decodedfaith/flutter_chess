import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Pawn extends ChessPiece {
  Pawn(PlayerColor color, Position position, {String? id})
      : super(color, 'pawn', position, id: id);

  @override
  Pawn copyWith({Position? position, bool? hasMoved}) {
    return Pawn(color, position ?? this.position, id: id);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-pawn.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    // White pawns move UP (increasing row: 2→3→4→8)
    // Black pawns move DOWN (decreasing row: 7→6→5→1)
    int direction = color == PlayerColor.white ? 1 : -1;
    int startRow = color == PlayerColor.white ? 2 : 7;

    // Moving forward one square
    if (toPosition.row == position.row + direction &&
        toPosition.col == position.col &&
        board.isEmpty(toPosition)) {
      return true;
    }

    // Moving forward two squares (only from start row)
    if (position.row == startRow &&
        toPosition.row == position.row + 2 * direction &&
        toPosition.col == position.col &&
        board.isEmpty(toPosition) &&
        board.isEmpty(
            Position(row: position.row + direction, col: position.col))) {
      return true;
    }

    // Capturing diagonally
    if (toPosition.row == position.row + direction &&
        (chessColToIndex(toPosition.col) == chessColToIndex(position.col) + 1 ||
            chessColToIndex(toPosition.col) ==
                chessColToIndex(position.col) - 1) &&
        !board.isEmpty(toPosition) &&
        board.getPiece(toPosition)!.color != color) {
      return true;
    }

    return false;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];
    // Consistent direction: white UP (+1), black DOWN (-1)
    int direction = color == PlayerColor.white ? 1 : -1;

    // Forward move
    Position forward =
        Position(row: position.row + direction, col: position.col);
    if (board.isEmpty(forward)) {
      moves.add(forward);

      // Two-square move from start position (rank 2 for white, rank 7 for black)
      if ((color == PlayerColor.white && position.row == 2) ||
          (color == PlayerColor.black && position.row == 7)) {
        Position twoStep =
            Position(row: position.row + 2 * direction, col: position.col);
        if (board.isEmpty(twoStep)) moves.add(twoStep);
      }
    }

    // Diagonal captures
    for (int offset in [-1, 1]) {
      int colInt = chessColToIndex(position.col) + offset;
      if (colInt >= 0 && colInt < 8) {
        Position diagonal = Position(
            row: position.row + direction, col: indexToChessCol(colInt));
        if (!board.isEmpty(diagonal) &&
            board.getPiece(diagonal)?.color != color) {
          moves.add(diagonal);
        }
      }
    }

    // Return moves (check validation happens in board.isValidMove separately)
    return moves;
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
