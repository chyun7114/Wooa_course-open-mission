import 'package:flutter/material.dart';
import '../../providers/multiplayer_game_provider.dart';

/// 최종 순위 화면
class RankingScreen extends StatelessWidget {
  final List<PlayerGameState> ranking;
  final String myPlayerId;

  const RankingScreen({
    super.key,
    required this.ranking,
    required this.myPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '🏆 최종 순위 🏆',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: ranking.length,
              itemBuilder: (context, index) {
                final player = ranking[index];
                final isMe = player.playerId == myPlayerId;
                return _buildRankingCard(player, isMe);
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(200, 48),
            ),
            child: const Text('방으로 돌아가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(PlayerGameState player, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[900] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: isMe ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          Text(
            _getRankEmoji(player.rank),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  '점수: ${player.score} | Lv.${player.level}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank위';
    }
  }
}
