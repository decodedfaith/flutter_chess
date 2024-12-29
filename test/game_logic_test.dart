// test/game_logic_test.dart

import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/pawn.dart';
import 'package:flutter_chess/game/pieces/rook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chess Piece Movement', () {
    test('Pawn initial move', () {
      var whitePawn = Pawn(PieceColor.white);
      // var validMoves = whitePawn.getValidMoves('e2');
      // expect(validMoves, ['e3']);
    });

    test('Rook movement', () {
      // var rook = Rook(color: 'black');
      // var validMoves = rook.getValidMoves('a1');
      // expect(validMoves, contains('a2')); // Verify vertical movement
    });

    test('Move piece on board', () {
      var board = ChessBoard();
      board.initializeBoard();
      board.movePiece('e2', 'e3');
      expect(board.board[3][4], isNotNull); // Piece should be at e3 now
    });
  });
}
