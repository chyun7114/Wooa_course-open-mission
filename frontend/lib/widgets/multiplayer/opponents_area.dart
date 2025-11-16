import 'package:flutter/material.dart';
import 'package:frontend/core/constants/ui_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/multiplayer_game_provider.dart';
import 'opponent_card.dart';
import 'ranking_screen.dart';

/// 상대방 영역 위젯
class OpponentsArea extends StatelessWidget {
  final String myPlayerId;

  const OpponentsArea({super.key, required this.myPlayerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplayerGameProvider>(
      builder: (context, multiProvider, child) {
        if (multiProvider.gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 게임 종료 시 순위 화면
        if (multiProvider.gameState!.isGameEnded &&
            multiProvider.gameState!.finalRanking != null) {
          return RankingScreen(
            ranking: multiProvider.gameState!.finalRanking!,
            myPlayerId: myPlayerId,
          );
        }

        // 상대방 목록
        final opponents = multiProvider.gameState!.players.values
            .where((p) => p.playerId != myPlayerId)
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(UIConstants.spacing),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(UIConstants.borderRadius),
                border: Border.all(color: Colors.grey[700]!, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildHeader(opponents.length),
                  const SizedBox(height: UIConstants.spacing),
                  Expanded(
                    child: opponents.isEmpty
                        ? _buildEmptyState()
                        : _buildOpponentGrid(opponents),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(int opponentCount) {
    return Row(
      children: [
        const Icon(Icons.people, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          '상대방 ($opponentCount명)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('상대방이 없습니다', style: TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildOpponentGrid(List<PlayerGameState> opponents) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 크기에 따라 열 개수 조정
        int crossAxisCount;
        if (constraints.maxWidth > 1000) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }
        
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: opponents.length,
          itemBuilder: (context, index) {
            return OpponentCard(
              opponent: opponents[index],
              myPlayerId: myPlayerId,
            );
          },
        );
      },
    );
  }

}
