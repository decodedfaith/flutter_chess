import 'package:flutter/material.dart';
import 'package:flutter_chess/models/captured_piece.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/widgets/captured_pieces_display.dart';

class GameHUD extends StatelessWidget {
  final String playerName;
  final PlayerColor playerColor;
  final bool isTurn;
  final List<CapturedPiece> capturedPieces;

  const GameHUD({
    super.key,
    required this.playerName,
    required this.playerColor,
    required this.isTurn,
    required this.capturedPieces,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBlack = playerColor == PlayerColor.black;
    final color = isBlack ? Colors.black : Colors.white;
    const textColor = Colors.white; // Always white text on dark background

    // Glassmorphism background for HUD
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _PlayerAvatar(color: color, isTurn: isTurn),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              if (isTurn)
                Text(
                  "Thinking...",
                  style: TextStyle(
                    color: Colors.greenAccent[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const Spacer(),
          CapturedPiecesDisplay(
            capturedPieces: capturedPieces,
            displayFor: playerColor,
          ),
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final Color color;
  final bool isTurn;

  const _PlayerAvatar({required this.color, required this.isTurn});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
