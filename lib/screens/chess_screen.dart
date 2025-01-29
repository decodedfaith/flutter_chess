import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
import 'package:flutter_chess/screens/user_profile.dart';
import 'package:flutter_svg/svg.dart';

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
          return _buildStateBody(context, state);
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

  Widget _buildStateBody(BuildContext context, ChessState state) {
    if (state is ChessInitial || state is MoveMade) {
      return _buildGameBoard(context, state);
    } else if (state is CheckState) {
      return Center(child: Text('${state.colorInCheck} is in check!'));
    } else if (state is Checkmate) {
      return Center(child: Text('${state.winner} wins by checkmate!'));
    } else {
      return const Center(child: Text('Unexpected state.'));
    }
  }

  Widget _buildGameBoard(BuildContext context, ChessState state) {
    final chessCubit = BlocProvider.of<ChessCubit>(context); // Access chessCubit

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 26, child: _buildMoveHistory()),
          const UserProfile(color: 'Black'),
          const SizedBox(height: 40),
          ChessBoardWidget(chessBoard: state.board, chessCubit: chessCubit), // Pass chessCubit
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