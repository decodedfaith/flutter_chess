import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_game.dart';
import 'package:flutter_chess/game/overlays/game_status_overlay.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/screens/game_hud.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard chessBoard;
  final ChessCubit chessCubit;

  const ChessBoardWidget(
      {super.key, required this.chessBoard, required this.chessCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        final board = state.board;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top HUD (Black)
            GameHUD(
              playerColor: PlayerColor.black,
              isTurn: board.currentTurn == PlayerColor.black,
              capturedPieces: board.capturedWhitePieces,
            ),
            // Game Board
            AspectRatio(
              aspectRatio: 1,
              child: GameWidget(
                game: ChessGame(chessCubit: chessCubit),
                overlayBuilderMap: {
                  'GameStatus': (context, game) => const GameStatusOverlay(),
                },
                initialActiveOverlays: const ['GameStatus'],
              ),
            ),
            // Bottom HUD (White)
            GameHUD(
              playerColor: PlayerColor.white,
              isTurn: board.currentTurn == PlayerColor.white,
              capturedPieces: board.capturedBlackPieces,
            ),
          ],
        );
      },
    );
  }
}
