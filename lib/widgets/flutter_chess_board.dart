import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/pieces/king.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_chess/utils/check_detector.dart';

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
        final isFlipped = state.isFlipped;
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

            // Visual row 0 = Rank 8 (White view) or Rank 1 (Black view/Flipped)
            final logicalRow = isFlipped ? (row + 1) : (8 - row);
            // Visual col 0 = File 'a' (White view) or File 'h' (Black view/Flipped)
            final logicalCol = isFlipped
                ? String.fromCharCode('h'.codeUnitAt(0) - col)
                : String.fromCharCode('a'.codeUnitAt(0) + col);

            final position = Position(row: logicalRow, col: logicalCol);

            // Check last move
            final isLastMove =
                state.lastMoveFrom == position || state.lastMoveTo == position;

            // Check if this square is selected or a valid move
            final isSelected = cubit.selectedPosition == position;
            final isValidMove = cubit.selectedPiece != null &&
                CheckDetector.getLegalMoves(state.board, cubit.selectedPiece!,
                        cubit.selectedPosition!)
                    .any((p) => p == position);

            // Check if king is in check at this position
            final pieceAtSquare = state.board.getPiece(position);
            final isKingInCheck = state is CheckState &&
                pieceAtSquare is King &&
                pieceAtSquare.color == state.colorInCheck;

            return GestureDetector(
              onTap: () => _handleSquareTap(context, position),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isKingInCheck
                          ? Colors.red.withValues(alpha: 0.5)
                          : isSelected
                              ? Colors.yellow.withValues(alpha: 0.6)
                              : isLastMove
                                  ? const Color(0xFFF5F682) // Highlight color
                                  : isLight
                                      ? const Color(0xFFEEEED2)
                                      : const Color(0xFF769656),
                      // Border for selection or check
                      border: isKingInCheck
                          ? Border.all(color: Colors.red, width: 4)
                          : null, // Removed excessive borders, rely on fill
                    ),
                    child: isValidMove
                        ? Center(
                            child: Container(
                              width: squareSize * 0.35,
                              height: squareSize * 0.35,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                    alpha: 0.2), // Subtle distinct dot
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  // Rank Label (1-8)
                  if (col == 0)
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Text(
                        '$logicalRow',
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF769656)
                              : const Color(0xFFEEEED2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // File Label (a-h)
                  if (row == 7)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Text(
                        logicalCol,
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF769656)
                              : const Color(0xFFEEEED2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
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
    final isFlipped = cubit.state.isFlipped;

    for (var row = 1; row <= 8; row++) {
      for (var colIndex = 0; colIndex < 8; colIndex++) {
        final col = String.fromCharCode('a'.codeUnitAt(0) + colIndex);
        final position = Position(col: col, row: row);
        final piece = board.getPiece(position);

        if (piece != null) {
          pieces.add(
            _buildAnimatedPiece(piece, position, squareSize, cubit, isFlipped),
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
    bool isFlipped,
  ) {
    // Convert logical position to pixel coordinates
    final colIndex = position.col.codeUnitAt(0) - 'a'.codeUnitAt(0);

    // If flipped, reverse col and row visual positions
    final visualCol = isFlipped ? (7 - colIndex) : colIndex;
    final visualRow = isFlipped ? (position.row - 1) : (8 - position.row);

    final left = visualCol * squareSize;
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
