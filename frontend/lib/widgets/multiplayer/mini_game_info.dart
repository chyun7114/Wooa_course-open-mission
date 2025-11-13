import 'package:flutter/material.dart';

/// 멀티플레이 화면용 간소화된 점수 정보
class MiniGameInfo extends StatelessWidget {
  final int score;
  final int level;
  final int lines;

  const MiniGameInfo({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.grey[700]!, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow('SCORE', score.toString()),
          const SizedBox(height: 8),
          _buildInfoRow('LEVEL', level.toString()),
          const SizedBox(height: 8),
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
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
