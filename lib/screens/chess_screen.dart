import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
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
    // Always show the board, overlays handle Check/Checkmate alerts
    final chessCubit = BlocProvider.of<ChessCubit>(context);
    return Center(
      child: ChessBoardWidget(chessBoard: state.board, chessCubit: chessCubit),
    );
  }
}
