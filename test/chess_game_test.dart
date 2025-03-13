import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';

void main() {
  group('Chess Game UI Tests', () {
    testWidgets('ChessBoardWidget renders correctly', (WidgetTester tester) async {
      final chessBoard = ChessBoard();
      final chessCubit = ChessCubit(); 
      
      chessBoard.initializeBoard();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChessBoardWidget(
              chessBoard: chessBoard,
              chessCubit: chessCubit, 
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
