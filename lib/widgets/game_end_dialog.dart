import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/models/player_color.dart';

/// Endgame dialog shown when game ends (checkmate, stalemate, resignation, timeout)
class GameEndDialog extends StatelessWidget {
  final PlayerColor? winner; // null for draw
  final GameEndReason reason;
  final int moveCount;
  final VoidCallback onNewGame;
  final VoidCallback onMainMenu;
  final VoidCallback onReview;

  const GameEndDialog({
    super.key,
    required this.winner,
    required this.reason,
    required this.moveCount,
    required this.onNewGame,
    required this.onMainMenu,
    required this.onReview,
  });

  String get _title {
    if (winner == null) {
      return reason == GameEndReason.stalemate ? 'Stalemate!' : 'Draw!';
    }
    return '${winner == PlayerColor.white ? 'White' : 'Black'} Wins!';
  }

  String get _subtitle {
    if (winner == null) {
      return reason == GameEndReason.stalemate
          ? 'No legal moves available'
          : 'Game ended in a draw';
    }
    switch (reason) {
      case GameEndReason.checkmate:
        return 'by Checkmate';
      case GameEndReason.resignation:
        return 'by Resignation';
      case GameEndReason.timeout:
        return 'on Time';
      case GameEndReason.abandoned:
        return 'Game Abandoned';
      default:
        return '';
    }
  }

  Color get _primaryColor {
    if (winner == null) return Colors.grey;
    return winner == PlayerColor.white
        ? Colors.yellow[700]!
        : Colors.grey[800]!;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              _primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy/Result Icon
            Icon(
              winner == null ? Icons.handshake : Icons.emoji_events,
              size: 64,
              color: _primaryColor,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),

            // Subtitle
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Game Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.numbers,
                    label: 'Moves',
                    value: '$moveCount',
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _StatItem(
                    icon: Icons.timer_outlined,
                    label: 'Type',
                    value: reason.name.toUpperCase(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Review Piece Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Review Game'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMainMenu,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _primaryColor),
                    ),
                    child: const Text('Menu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNewGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('New Game'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
