import 'package:flutter/material.dart';
import 'package:flutter_chess/models/player_color.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PromotionDialog extends StatelessWidget {
  final PlayerColor color;
  final Function(String) onSelect;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Promote Pawn To:'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOption(context, 'queen'),
          _buildOption(context, 'rook'),
          _buildOption(context, 'bishop'),
          _buildOption(context, 'knight'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String type) {
    final assetPath = 'assets/chess_pieces_svg/${color.name}-$type.svg';
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelect(type);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          assetPath,
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}
