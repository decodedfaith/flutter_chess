import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class Rook extends ChessPiece {
  List<String> columnPositions = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  Rook(PlayerColor color, Position position, {String? id})
      : super(color, 'rook', position, id: id);

  @override
  Rook copyWith({Position? position}) {
    return Rook(color, position ?? this.position, id: id);
  }

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-rook.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    if (toPosition.row != position.row && toPosition.col != position.col) {
      return false; // Rook moves must be in the same row or column
    }

    // Determine the direction of movement
    int stepX = toPosition.col == position.col
        ? 0
        : (columnPositions.indexOf(toPosition.col) >
                columnPositions.indexOf(position.col)
            ? 1
            : -1);
    int stepY = toPosition.row == position.row
        ? 0
        : (toPosition.row > position.row ? 1 : -1);

    // Traverse the path and check for blocking pieces
    for (int x = chessColToIndex(position.col) + stepX,
            y = position.row + stepY;
        (x != chessColToIndex(toPosition.col) || y != toPosition.row);
        x += stepX, y += stepY) {
      if (!board.isEmpty(Position(row: y, col: indexToChessCol(x)))) {
        return false; // Path is blocked
      }
    }

    // Validate the destination
    ChessPiece? targetPiece = board.getPiece(toPosition);
    return targetPiece == null || targetPiece.color != color;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];

    // Horizontal and vertical directions
    List<List<int>> directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ];

    for (var direction in directions) {
      int newRow = position.row;
      int newCol = chessColToIndex(position.col);
      while (true) {
        newRow += direction[0];
        newCol += direction[1];
        Position next = Position(row: newRow, col: indexToChessCol(newCol));

        if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
        if (board.isEmpty(next)) {
          moves.add(next);
        } else {
          if (board.getPiece(next)?.color != color) moves.add(next);
          break;
        }
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
