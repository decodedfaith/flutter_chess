import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/models/player_color.dart';

void main() {
  group('Chess Game - Basic Tests', () {
    test('Chess board can be initialized', () {
      final board = ChessBoard();
      board.initializeBoard();

      expect(board.currentTurn, PlayerColor.white);
      expect(board, isNotNull);
    });

    test('Chess board has 64 squares', () {
      final board = ChessBoard();
      expect(board.columnPositions.length, 8);
      expect(board.rowPositions.length, 8);
    });
  });
}
