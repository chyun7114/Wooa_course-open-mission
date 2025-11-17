import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ranking_provider.dart';

class RankingPanelWidget extends StatelessWidget {
  const RankingPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingProvider>(
      builder: (context, rankingProvider, child) {
        final rankings = rankingProvider.topRankings;
        final isLoading = rankingProvider.isLoading;

        return Container(
          width: 280,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOP 10 RANKING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<RankingProvider>().fetchTopRankings();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (rankings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No rankings yet',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ),
                )
              else
                ...rankings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ranking = entry.value;
                  return _buildRankingItem(
                    rank: index + 1,
                    score: ranking.score,
                    nickname: ranking.nickname,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required int score,
    required String nickname,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
    } else if (rank == 3) {
      rankColor = Colors.orange[300]!;
    } else {
      rankColor = Colors.white70;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontSize: rank <= 3 ? 16 : 14,
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Player name/ID
          Expanded(
            child: Text(
              nickname,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Score
          Text(
            score.toString(),
            style: TextStyle(
              color: rankColor,
              fontSize: rank <= 3 ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
