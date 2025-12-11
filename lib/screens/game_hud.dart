import 'package:flutter/material.dart';
import 'package:flutter_chess/models/captured_piece.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/widgets/captured_pieces_display.dart';

class GameHUD extends StatelessWidget {
  final PlayerColor playerColor;
  final bool isTurn;
  final List<CapturedPiece> capturedPieces;

  const GameHUD({
    super.key,
    required this.playerColor,
    required this.isTurn,
    required this.capturedPieces,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBlack = playerColor == PlayerColor.black;
    final color = isBlack ? Colors.black : Colors.white;
    final textColor = isBlack ? Colors.white : Colors.black;
    final backgroundColor = isBlack ? Colors.grey[900]! : Colors.grey[300]!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: backgroundColor,
      child: Row(
        children: [
          _PlayerAvatar(color: color, isTurn: isTurn),
          const SizedBox(width: 12),
          Text(
            isBlack ? "Black Player" : "White Player",
            style: TextStyle(
              color: textColor,
              fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
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
