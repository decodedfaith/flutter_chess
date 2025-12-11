import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlutterChessBoard extends StatelessWidget {
  const FlutterChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        final board = state.board;
        final cubit = context.read<ChessCubit>();

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate board size
            final boardSize = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            final squareSize = boardSize / 8;

            return SizedBox(
              width: boardSize,
              height: boardSize,
              child: Stack(
                children: [
                  // Board background (64 squares)
                  _buildBoardBackground(squareSize, cubit),

                  // Pieces (animated positions)
                  ..._buildPieces(board, squareSize, cubit),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBoardBackground(double squareSize, ChessCubit cubit) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final isLight = (row + col) % 2 == 0;

            // Visual row 0 = Rank 8, Visual row 7 = Rank 1
            final logicalRow = 8 - row;
            final logicalCol = String.fromCharCode('a'.codeUnitAt(0) + col);
            final position = Position(row: logicalRow, col: logicalCol);

            // Check if king is in check at this position
            final pieceAtSquare = state.board.getPiece(position);
            final isKingInCheck = state is CheckState &&
                pieceAtSquare is King &&
                pieceAtSquare.color == state.colorInCheck;

            return GestureDetector(
              onTap: () => _handleSquareTap(context, position),
              child: Container(
                decoration: BoxDecoration(
                  color: isLight
                      ? const Color(0xFFEEEED2)
                      : const Color(0xFF769656),
                  border: isSelected
                      ? Border.all(color: Colors.yellow, width: 3)
                      : isKingInCheck
                          ? Border.all(color: Colors.red, width: 4)
                          : null,
                ),
                child: isValidMove
                    ? Center(
                        child: Container(
                          width: squareSize * 0.3,
                          height: squareSize * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPieces(
      ChessBoard board, double squareSize, ChessCubit cubit) {
    final pieces = <Widget>[];

    for (var row = 1; row <= 8; row++) {
      for (var colIndex = 0; colIndex < 8; colIndex++) {
        final col = String.fromCharCode('a'.codeUnitAt(0) + colIndex);
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece != null) {
          pieces.add(
            _buildAnimatedPiece(piece, position, squareSize, cubit),
          );
        }
      }
    }

    return pieces;
  }

  Widget _buildAnimatedPiece(
    ChessPiece piece,
    Position position,
    double squareSize,
    ChessCubit cubit,
  ) {
    // Convert logical position to pixel coordinates
    // Col 'a' = 0, 'h' = 7
    final colIndex = position.col.codeUnitAt(0) - 'a'.codeUnitAt(0);
    // Row 8 = top (y=0), Row 1 = bottom (y=7*squareSize)
    final visualRow = 8 - position.row;

    final left = colIndex * squareSize;
    final top = visualRow * squareSize;

    return AnimatedPositioned(
      key: ValueKey(piece.id),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      width: squareSize,
      height: squareSize,
      child: GestureDetector(
        onTap: () => _handlePieceTap(cubit, position),
        child: SvgPicture.asset(
          piece.getSvgAssetPath(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _handleSquareTap(BuildContext context, Position position) {
    final cubit = context.read<ChessCubit>();
    final board = cubit.state.board;

    if (cubit.selectedPiece == null) {
      // Try to select piece at this position
      cubit.selectPiece(position);
    } else {
      // Try to move selected piece to this position
      final pieceAtTarget = board.getPiece(position);
      if (pieceAtTarget != null &&
          pieceAtTarget.color == cubit.selectedPiece!.color) {
        // Select different piece of same color
        cubit.selectPiece(position);
      } else {
        // Attempt move
        cubit.makeMove(cubit.selectedPosition!, position);
        cubit.selectedPiece = null;
        cubit.selectedPosition = null;
      }
    }
  }

  void _handlePieceTap(ChessCubit cubit, Position position) {
    if (cubit.selectedPiece == null) {
      cubit.selectPiece(position);
    } else {
      // Tapping a piece while another is selected
      final board = cubit.state.board;
      final tappedPiece = board.getPiece(position);

      if (tappedPiece != null &&
          tappedPiece.color == cubit.selectedPiece!.color) {
        // Select this piece instead
        cubit.selectPiece(position);
      } else {
        // Try to move to this square (capture)
        cubit.makeMove(cubit.selectedPosition!, position);
        cubit.selectedPiece = null;
        cubit.selectedPosition = null;
      }
    }
  }
}
