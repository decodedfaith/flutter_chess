import 'package:flutter/material.dart';
import 'package:flutter_chess/models/captured_piece.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Chess.com-style captured pieces display with material advantage
class CapturedPiecesDisplay extends StatelessWidget {
  final List<CapturedPiece> capturedPieces;
  final PlayerColor displayFor; // Which player's HUD this is for

  const CapturedPiecesDisplay({
    super.key,
    required this.capturedPieces,
    required this.displayFor,
  });

  /// Group pieces by type and count them
  Map<String, int> _groupPieces() {
    final Map<String, int> grouped = {};
    for (final piece in capturedPieces) {
      grouped[piece.type] = (grouped[piece.type] ?? 0) + 1;
    }
    return grouped;
  }

  /// Calculate total material value
  int _calculateMaterialValue() {
    return capturedPieces.fold(0, (sum, piece) => sum + piece.value);
  }

  @override
  Widget build(BuildContext context) {
    if (capturedPieces.isEmpty) {
      return const SizedBox.shrink();
    }

    final grouped = _groupPieces();
    final materialValue = _calculateMaterialValue();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grouped pieces display
        ...grouped.entries.map((entry) {
          final type = entry.key;
          final count = entry.value;
          final piece = capturedPieces.firstWhere((p) => p.type == type);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                piece.getSvgAssetPath(),
                height: 20,
                width: 20,
              ),
              if (count > 1) ...[
                const SizedBox(width: 2),
                Text(
                  '×$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: displayFor == PlayerColor.white
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ],
              const SizedBox(width: 6),
            ],
          );
        }).toList(),

        // Material advantage indicator
        if (materialValue > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Text(
              '+$materialValue',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
