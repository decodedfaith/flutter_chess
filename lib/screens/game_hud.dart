import 'package:flutter/material.dart';
import 'package:flutter_chess/models/captured_piece.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_chess/widgets/captured_pieces_display.dart';

class GameHUD extends StatelessWidget {
  final String playerName;
  final PlayerColor playerColor;
  final bool isTurn;
  final List<CapturedPiece> capturedPieces;
  final Duration timeRemaining;
  final bool isThinking;

  const GameHUD({
    super.key,
    required this.playerName,
    required this.playerColor,
    required this.isTurn,
    required this.capturedPieces,
    required this.timeRemaining,
    this.isThinking = false,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final bool isBlack = playerColor == PlayerColor.black;
    final color = isBlack ? Colors.black : Colors.white;
    const textColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          _PlayerAvatar(color: color, isTurn: isTurn),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                    const SizedBox(width: 8),
                    if (isThinking) _ThinkingIndicator(),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTurn
                            ? const Color(0xFF81B64C).withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isTurn
                              ? const Color(0xFF81B64C).withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _formatDuration(timeRemaining),
                        style: TextStyle(
                          color: isTurn ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CapturedPiecesDisplay(
            capturedPieces: capturedPieces,
            displayFor: playerColor,
          ),
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatefulWidget {
  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final opacity = ((_controller.value * 3 - index) % 3) / 3;
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF81B64C)
                    .withValues(alpha: opacity.clamp(0.2, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTurn ? const Color(0xFF81B64C) : Colors.grey.shade800,
          width: 2,
        ),
        boxShadow: isTurn
            ? [
                BoxShadow(
                  color: const Color(0xFF81B64C).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Icon(
        Icons.person,
        color: color == Colors.black ? Colors.white38 : Colors.black45,
        size: 24,
      ),
    );
  }
}
