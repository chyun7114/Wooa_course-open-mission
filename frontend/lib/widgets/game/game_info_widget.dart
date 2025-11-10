import 'package:flutter/material.dart';

class GameInfoWidget extends StatelessWidget {
  final int score;
  final int level;
  final int lines;

  const GameInfoWidget({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow('SCORE', score.toString()),
          const SizedBox(height: 12),
          _buildInfoRow('LEVEL', level.toString()),
          const SizedBox(height: 12),
          _buildInfoRow('LINES', lines.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
