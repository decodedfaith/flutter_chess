import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_game.dart';
import 'package:flutter_chess/game/overlays/game_info_overlay.dart';

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard chessBoard;
  final ChessCubit chessCubit;

  const ChessBoardWidget(
      {super.key, required this.chessBoard, required this.chessCubit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: GameWidget(
          game: ChessGame(chessCubit: chessCubit),
          overlayBuilderMap: {
            'GameInfo': (context, game) => const GameInfoOverlay(),
          },
          initialActiveOverlays: const ['GameInfo'],
        ),
      ),
    );
  }
}
