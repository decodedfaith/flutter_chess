import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/utils/check_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Strict Check Rules', () {
    test('King cannot move into check', () {
      final board = ChessBoard();
      board.initializeBoard();
      // Clear board specific setup
      board.board.forEach((col, rows) =>
          rows.forEach((row, _) => board.board[col]![row] = null));

      // White King at e1
      final whiteKing = King(PlayerColor.white, Position(col: 'e', row: 1));
      board.board['e']![1] = whiteKing;

      // Black Rook at e8 (Attacking file 'e')
      final blackRook = Rook(PlayerColor.black, Position(col: 'e', row: 8));
      board.board['e']![8] = blackRook;

      // Try moving King to e2 (into check)
      final legalMoves = CheckDetector.getLegalMoves(
          board, whiteKing, Position(col: 'e', row: 1));

      // Should NOT contain e2
      expect(legalMoves.contains(Position(col: 'e', row: 2)), isFalse);

      // Should contain d1, f1 (if valid)
      expect(legalMoves.contains(Position(col: 'd', row: 1)), isTrue);
    });

    test('Pinned piece cannot move if exposing King', () {
      final board = ChessBoard();
      board.initializeBoard();
      board.board.forEach((col, rows) =>
          rows.forEach((row, _) => board.board[col]![row] = null));

      // White King at e1
      final whiteKing = King(PlayerColor.white, Position(col: 'e', row: 1));
      board.board['e']![1] = whiteKing;

      // White Rook at e2 (Pinned)
      final whiteRook = Rook(PlayerColor.white, Position(col: 'e', row: 2));
      board.board['e']![2] = whiteRook;

      // Black Rook at e8 (Pinning the White Rook)
      final blackRook = Rook(PlayerColor.black, Position(col: 'e', row: 8));
      board.board['e']![8] = blackRook;

      // Try moving White Rook to d2 (leaving e-file, exposing King)
      final legalMoves = CheckDetector.getLegalMoves(
          board, whiteRook, Position(col: 'e', row: 2));

      // Should ONLY be able to move along file e (e3..e7)
      expect(legalMoves.contains(Position(col: 'd', row: 2)), isFalse);
      expect(legalMoves.contains(Position(col: 'e', row: 3)), isTrue);
    });
  });
}
