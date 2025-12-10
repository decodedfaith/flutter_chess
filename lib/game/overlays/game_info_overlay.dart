import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GameInfoOverlay extends StatelessWidget {
  const GameInfoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChessCubit, ChessState>(
      builder: (context, state) {
        final board = state.board;
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

        return SafeArea(
          child: Stack(
            children: [
              // Top Bar (Black's Captured Pieces & Turn Indicator if Black)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      // Player Info
                      _PlayerInfo(
                        name: "Black",
                        isTurn: board.currentTurn == PlayerColor.black,
                        color: Colors.black,
                      ),
                      const Spacer(),
                      // Captured White Pieces (Displayed on Black's side)
                      _CapturedPieces(pieces: board.capturedWhitePieces),
                    ],
                  ),
                ),
              ),

              // Bottom Bar (White's Captured Pieces & Turn Indicator if White)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      // Player Info
                      _PlayerInfo(
                        name: "White",
                        isTurn: board.currentTurn == PlayerColor.white,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      // Captured Black Pieces (Displayed on White's side)
                      _CapturedPieces(pieces: board.capturedBlackPieces),
                    ],
                  ),
                ),
              ),

              // Center Status Notification (Check/Checkmate)
              if (statusText.isNotEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
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
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  final String name;
  final bool isTurn;
  final Color color;

  const _PlayerInfo({
    required this.name,
    required this.isTurn,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
            boxShadow: isTurn
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _CapturedPieces extends StatelessWidget {
  final List<ChessPiece> pieces;

  const _CapturedPieces({required this.pieces});

  @override
  Widget build(BuildContext context) {
    // Group pieces for compact display (e.g. Pawn x5) if needed,
    // but for now simple row list
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pieces.map((piece) {
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: SvgPicture.asset(
            piece.getSvgAssetPath(),
            height: 20,
            width: 20,
          ),
        );
      }).toList(),
    );
  }
}
