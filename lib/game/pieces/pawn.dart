import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Pawn extends ChessPiece {
  Pawn(PlayerColor color, Position position, {String? id})
      : super(color, 'pawn', position, id: id);

  @override
  Pawn copyWith({Position? position}) {
    return Pawn(color, position ?? this.position, id: id);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-pawn.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int direction =
        color == PlayerColor.white ? 1 : -1; // White moves up, black moves down
    int startRow = color == PlayerColor.white
        ? 1
        : 6; // Start rows for white (1) and black (6)

    // Moving forward one square
    if (toPosition.row == position.row + direction &&
        toPosition.col == position.col &&
        board.isEmpty(toPosition)) {
      return true;
    }

    // Moving forward two squares (only on the first move)
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
    int direction =
        color == PlayerColor.white ? -1 : 1; // White moves up, Black moves down

    // Forward move
    Position forward =
        Position(row: position.row + direction, col: position.col);
    if (board.isEmpty(forward)) {
      moves.add(forward);

      // Two-square move from initial position
      if ((color == PlayerColor.white && position.row == 6) ||
          (color == PlayerColor.black && position.row == 1)) {
        Position twoStep =
            Position(row: position.row + 2 * direction, col: position.col);
        if (board.isEmpty(twoStep)) moves.add(twoStep);
      }
    }

    // Diagonal captures
    for (int offset in [-1, 1]) {
      int colInt = chessColToIndex(position.col) + offset;
      Position diagonal =
          Position(row: position.row + direction, col: indexToChessCol(colInt));
      if (!board.isEmpty(diagonal) &&
          board.getPiece(diagonal)?.color != color) {
        moves.add(diagonal);
      }
    }

    return moves
        .where((move) => board.isValidMove(position, move, this))
        .toList();
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
