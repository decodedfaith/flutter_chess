import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece_svg.dart';
import 'package:flutter_chess/game/position.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard chessBoard;
  final ChessCubit chessCubit;

   // Chess columns and rows
  final List<int> rowPositions = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> columnPositions = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];


  ChessBoardWidget({super.key, required this.chessBoard, required this.chessCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: 1, // Ensure the chessboard is square
          child: Stack(
            children: [
              // Chessboard Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8, // 8 columns for the chessboard
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 8; // Calculate row (0-7)
                  final col = index % 8; // Calculate column (0-7)
                  final colLetter = columnPositions[col]; // Convert column index to letter ('a' to 'h')
                  final piece = chessBoard.board[colLetter]?[rowPositions[row]];
        
                  return GestureDetector(
                    onTap: (){
                      if (chessCubit.selectedPiece == null) {
                      chessCubit.selectPiece(Position(col: indexToChessCol(col), row: row));
                      } else {
                        chessCubit.makeMove(Position(col: indexToChessCol(col), row: row), chessCubit.selectedPosition!);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (row + col) % 2 == 0 ? Colors.white : Colors.grey,
                        border: Border.all(color: Colors.red),
                      ),
                      child: 
                      
                      piece != null
                          ? ChessPieceSvg(chessPiece: piece) // Display chess piece
                          : null,
                    ),
                  );
                },
              ),
              // Row labels (1–8)
              Positioned.fill(
                child: Column(
                  children: List.generate(
                    8,
                    (row) => Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            '${8 - row}', // Numbers decrease as you go up
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Column labels (A–H)
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(), // Empty space to align labels at the bottom
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0, right: 10),
                      child: Row(
                        children: List.generate(
                          8,
                          (col) => Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                String.fromCharCode(65 + col).toLowerCase(), // A–H
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
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