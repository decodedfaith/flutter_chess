import 'package:flutter/material.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chess/game/chess_board.dart';

void main() {
  group('Chess Game UI Tests', () {
    testWidgets('ChessBoardWidget renders correctly', (WidgetTester tester) async {
  // Arrange: Create and initialize the ChessBoard
  final chessBoard = ChessBoard();
  chessBoard.initializeBoard();

  // Act: Pump the widget tree
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChessBoardWidget(chessBoard: chessBoard),
      ),
    ),
  );

  // Assert: Verify rendering of pieces
  expect(find.byType(GridView), findsOneWidget, reason: 'GridView should be present');
});


  }
  );
}
