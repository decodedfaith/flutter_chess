// // lib/game/chess_piece.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';

class King extends ChessPiece {
  final bool hasMoved;

  King(PlayerColor color, Position position,
      {this.hasMoved = false, String? id})
      : super(color, 'king', position, id: id);

  @override
  King copyWith({Position? position, bool? hasMoved}) {
    return King(color, position ?? this.position,
        hasMoved: hasMoved ?? this.hasMoved, id: id);
  }

  @override
  String get fenChar => color == PlayerColor.white ? 'K' : 'k';

  @override
  String getSvgAssetPath() {
    return 'assets/chess_pieces_svg/${color.name}-king.svg';
  }

  @override
  bool isValidMove(Position toPosition, ChessBoard board) {
    int dx =
        (chessColToIndex(toPosition.col) - chessColToIndex(position.col)).abs();
    int dy = (toPosition.row - position.row).abs();

    // King moves one square in any direction
    if (dx <= 1 && dy <= 1) {
      if (board.isEmpty(toPosition) ||
          board.getPiece(toPosition)!.color != color) {
        return true;
      }
    }

    // Castling Logic (2 squares horizontal)
    if (dy == 0 && dx == 2 && !hasMoved) {
      // Check if it's a valid castling target
      if (toPosition.col == 'g') {
        // Kingside
        return _canCastleKingside(board);
      } else if (toPosition.col == 'c') {
        // Queenside
        return _canCastleQueenside(board);
      }
    }

    return false;
  }

  @override
  List<Position> getValidMoves(ChessBoard board) {
    List<Position> moves = [];
    List<List<int>> offsets = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ];

    for (var offset in offsets) {
      int newRow = position.row + offset[0];
      int newCol = chessColToIndex(position.col) + offset[1];

      // Correct bounds: rows are 1-8, cols are 0-7
      if (newRow >= 1 && newRow <= 8 && newCol >= 0 && newCol < 8) {
        Position move = Position(row: newRow, col: indexToChessCol(newCol));
        if (board.isEmpty(move) || board.getPiece(move)?.color != color) {
          moves.add(move);
        }
      }
    }

    // Add valid castling moves
    if (!hasMoved) {
      if (_canCastleKingside(board)) {
        moves.add(Position(row: position.row, col: 'g'));
      }
      if (_canCastleQueenside(board)) {
        moves.add(Position(row: position.row, col: 'c'));
      }
    }

    return moves; // Check validation happens separately
  }

  bool _canCastleKingside(ChessBoard board) {
    // 1. King must not have moved (checked by caller)
    // 2. Rook at h-file must exist and not have moved
    int row = color == PlayerColor.white ? 1 : 8;
    ChessPiece? rook = board.getPiece(Position(row: row, col: 'h'));

    // Check Rook
    if (rook is! Rook || rook.color != color || rook.hasMoved) {
      return false;
    }

    // 3. Path must be clear (f and g)
    if (!board.isEmpty(Position(row: row, col: 'f')) ||
        !board.isEmpty(Position(row: row, col: 'g'))) {
      return false;
    }

    return true;
  }

  bool _canCastleQueenside(ChessBoard board) {
    // 1. King must not have moved (checked by caller)
    // 2. Rook at a-file must exist and not have moved
    int row = color == PlayerColor.white ? 1 : 8;
    ChessPiece? rook = board.getPiece(Position(row: row, col: 'a'));

    // Check Rook
    if (rook is! Rook || rook.color != color || rook.hasMoved) {
      return false;
    }

    // 3. Path must be clear (b, c, d)
    if (!board.isEmpty(Position(row: row, col: 'b')) ||
        !board.isEmpty(Position(row: row, col: 'c')) ||
        !board.isEmpty(Position(row: row, col: 'd'))) {
      return false;
    }

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
