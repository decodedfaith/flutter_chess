import 'package:flutter/material.dart';

class ReviewControls extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFirst;
  final VoidCallback onLast;
  final int currentIndex;
  final int totalMoves;

  const ReviewControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.onFirst,
    required this.onLast,
    required this.currentIndex,
    required this.totalMoves,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Review Mode: ${currentIndex + 1} / $totalMoves',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(Icons.first_page, onFirst, currentIndex > -1),
              _buildButton(Icons.chevron_left, onPrevious, currentIndex > -1),
              _buildButton(
                  Icons.chevron_right, onNext, currentIndex < totalMoves - 1),
              _buildButton(
                  Icons.last_page, onLast, currentIndex < totalMoves - 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return IconButton(
      icon: Icon(icon, color: enabled ? Colors.white : Colors.grey[700]),
      iconSize: 32,
      onPressed: enabled ? onPressed : null,
    );
  }
}
