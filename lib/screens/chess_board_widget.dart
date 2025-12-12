import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/screens/game_hud.dart';
import 'package:flutter_chess/widgets/flutter_chess_board.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard chessBoard;
  final ChessCubit chessCubit;
  final String whitePlayerName;
  final String blackPlayerName;

  const ChessBoardWidget({
    super.key,
    required this.chessBoard,
    required this.chessCubit,
    required this.whitePlayerName,
    required this.blackPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        final board = state.board;
        return LayoutBuilder(
          builder: (context, constraints) {
            // Premium Layout: Maximize board, push HUDs to edges
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Calculate board size (square)
            double boardSize = availableWidth < availableHeight
                ? availableWidth
                : availableHeight * 0.65; // Leave room for HUDs

            // Ensure padding
            boardSize = boardSize - 32;

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top HUD (Black)
                    GameHUD(
                      playerName: blackPlayerName,
                      playerColor: PlayerColor.black,
                      isTurn: board.currentTurn == PlayerColor.black,
                      capturedPieces: board.capturedWhitePieces,
                    ),

                    const Spacer(),

                    // Game Board Area
                    Center(
                      child: Container(
                        width: boardSize,
                        height: boardSize,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const FlutterChessBoard(),
                      ),
                    ),

                    const Spacer(),

                    // Bottom HUD (White)
                    GameHUD(
                      playerName: whitePlayerName, // Pass real name
                      playerColor: PlayerColor.white,
                      isTurn: board.currentTurn == PlayerColor.white,
                      capturedPieces: board.capturedBlackPieces,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
