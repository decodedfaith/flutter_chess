import 'package:flutter/material.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';

class ChessGameScreen extends StatelessWidget {
  final ChessBoard chessBoard = ChessBoard();

  ChessGameScreen({super.key}) {
    chessBoard.initializeBoard(); // Initialize the board with pieces
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
      ),
      body: ChessBoardWidget(chessBoard: chessBoard),
    );
  }
}
