// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChessCubit()..initializeBoard(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChessScreen(),
      ),
    );
  }
}

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: _buildAppBarTitle(),
        centerTitle: true,
      ),
      body: BlocBuilder<ChessCubit, ChessState>(
        builder: (context, state) {
          return _buildStateBody(state);
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/chess_pieces_svg/black-pawn.svg',
          height: 30.0,
        ),
        const SizedBox(width: 4.0),
        const Text(
          'flutter.Chess',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStateBody(ChessState state) {
    if (state is ChessInitial || state is MoveMade) {
      return _buildGameBoard(state);
    } else if (state is CheckState) {
      return Center(child: Text('${state.colorInCheck} is in check!'));
    } else if (state is Checkmate) {
      return Center(child: Text('${state.winner} wins by checkmate!'));
    } else {
      return const Center(child: Text('Unexpected state.'));
    }
  }

  Widget _buildGameBoard(ChessState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 26, child: _buildMoveHistory()),
          const UserProfile(color: 'Black'),
          const SizedBox(height: 40),
          ChessBoardWidget(chessBoard: state.board),
          const SizedBox(height: 40),
          const UserProfile(color: 'White'),
          const Text(
            'User Stats or Info',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveHistory() {
    return Container(
      color: Colors.grey,
      child: const Text("1. e4  d5  2. exd5 Qxd5 3. Nc3"),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.color});

  final String color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 20),
        const SizedBox(width: 8),
        Text(
          '$color Player',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        const Text(
          '3 Days',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
