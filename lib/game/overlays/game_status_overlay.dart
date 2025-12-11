import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:google_fonts/google_fonts.dart';

class GameStatusOverlay extends StatelessWidget {
  const GameStatusOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        String statusText = '';
        Color statusColor = Colors.transparent;

        if (state is Checkmate) {
          statusText = 'CHECKMATE! ${state.winner.name.toUpperCase()} WINS';
          statusColor = Colors.red.withValues(alpha: 0.8);
        } else if (state is CheckState) {
          statusText = 'CHECK!';
          statusColor = Colors.orange.withValues(alpha: 0.8);
        } else if (state is Stalemate) {
          statusText = 'STALEMATE';
          statusColor = Colors.grey.withValues(alpha: 0.8);
        }

        if (statusText.isEmpty) return const SizedBox.shrink();

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.oswald(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
