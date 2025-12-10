import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/components/board_component.dart';

class ChessGame extends FlameGame {
  final ChessCubit chessCubit;

  ChessGame({required this.chessCubit});

  late final BoardComponent boardComponent;

  @override
  Color backgroundColor() => const Color(0xFF302E2B); // Dark background

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add the Bloc provider listener to the game to react to state changes
    await add(
      FlameBlocProvider<ChessCubit, ChessState>.value(
        value: chessCubit,
        children: [
          boardComponent = BoardComponent(),
        ],
      ),
    );

    // Position the board in the center
    boardComponent.position = size / 2;
    boardComponent.anchor = Anchor.center;
  }
}
