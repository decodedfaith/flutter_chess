// test/game_logic_test.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chess Piece Movement', () {
    test('Pawn initial move', () {
      var whitePawn = Pawn(PlayerColor.white, Position(row: 1, col: 4)); // Pawn starts at e2
      var board = ChessBoard();
      board.initializeBoard();

      // Test that the pawn's first move can be forward one or two squares
      expect(whitePawn.isValidMove(Position(row: 3, col: 4), board), isTrue); // Valid move to e3
      expect(whitePawn.isValidMove(Position(row: 4, col: 4), board), isTrue); // Valid move to e4 on first move
    });

    test('Rook movement', () {
      var blackRook = Rook(PlayerColor.black, Position(row: 0, col: 0)); // Rook starts at a1
      var board = ChessBoard();
      board.initializeBoard();

      // Test valid rook moves
      expect(blackRook.isValidMove(Position(row: 1, col: 0), board), isTrue); // Move to a2
      expect(blackRook.isValidMove(Position(row: 0, col: 1), board), isTrue); // Move to b1
      expect(blackRook.isValidMove(Position(row: 1, col: 1), board), isFalse); // Invalid diagonal move
    });

    test('Move piece on board', () {
      var board = ChessBoard();
      board.initializeBoard();

      // Use the Position class for coordinates
      Position fromPosition = Position(row: 1, col: 4); // 'e2' in chess notation
      Position toPosition = Position(row: 2, col: 4);   // 'e3' in chess notation

      board.movePiece(fromPosition, toPosition);

      // Assert that the piece moved correctly
      expect(board.board[2][4], isNotNull); // Piece should be at e3 now
      expect(board.board[1][4], isNull);    // Piece should no longer be at e2
    });

  });
}
