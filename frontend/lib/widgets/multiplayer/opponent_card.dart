import 'package:flutter/material.dart';
import '../../providers/multiplayer_game_provider.dart';
import 'mini_board_widget.dart';

/// 상대방 게임 카드 위젯
class OpponentCard extends StatelessWidget {
  final PlayerGameState opponent;
  final String? myPlayerId;

  const OpponentCard({super.key, required this.opponent, this.myPlayerId});

  @override
  Widget build(BuildContext context) {
    final hasBoard = opponent.board != null && opponent.board!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: opponent.isAlive ? Colors.grey[850] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: opponent.isAlive
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(hasBoard),
          if (!opponent.isAlive && opponent.rank > 0) ...[
            const SizedBox(height: 2),
            _buildRankBadge(),
          ],
          const SizedBox(height: 6),
          Expanded(
            child: hasBoard
                ? MiniBoardWidget(board: opponent.board!)
                : _buildWaitingPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool hasBoard) {
    return Row(
      children: [
        Icon(
          opponent.isAlive ? Icons.check_circle : Icons.cancel,
          color: opponent.isAlive ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            opponent.nickname,
            style: TextStyle(
              color: opponent.isAlive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (hasBoard) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text('🎮', style: TextStyle(fontSize: 9)),
          ),
        ],
      ],
    );
  }

  Widget _buildRankBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${opponent.rank}위',
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWaitingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_4x4, color: Colors.grey[600], size: 20),
            const SizedBox(height: 4),
            Text(
              '대기 중...',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStats() {
  //   return Column(
  //     children: [
  //       _buildStatRow(Icons.stars, '점수', opponent.score.toString()),
  //       _buildStatRow(Icons.trending_up, '레벨', 'Lv.${opponent.level}'),
  //       _buildStatRow(
  //         Icons.format_list_numbered,
  //         '라인',
  //         '${opponent.linesCleared}',
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildStatRow(IconData icon, String label, String value) {
  //   return Row(
  //     children: [
  //       Icon(icon, size: 14, color: Colors.white70),
  //       const SizedBox(width: 4),
  //       Text(
  //         '$label: ',
  //         style: const TextStyle(color: Colors.white60, fontSize: 11),
  //       ),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 11,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
