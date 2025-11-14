import 'package:flutter/material.dart';

class OpponentBoard extends StatelessWidget {
  final String playerName;
  final List<List<int>> board;
  final bool isAlive;
  final int score;

  const OpponentBoard({
    super.key,
    required this.playerName,
    required this.board,
    required this.isAlive,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAlive ? Colors.grey[700]! : Colors.red,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // 플레이어 정보
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isAlive ? Colors.grey[800] : Colors.red[900],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        playerName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isAlive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 점수
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                color: Colors.grey[850],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      score.toString(),
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 게임 보드
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 0.5,
                    child: _buildMiniBoard(),
                  ),
                ),
              ),
            ],
          ),

          // 죽은 경우 X 표시 오버레이
          if (!isAlive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 80,
                    color: Colors.red.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniBoard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 10;

          return Column(
            children: List.generate(
              20,
              (row) => Row(
                children: List.generate(10, (col) {
                  final cellValue = board[row][col];
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: _getCellColor(cellValue),
                      border: Border.all(color: Colors.grey[900]!, width: 0.5),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCellColor(int value) {
    if (value == 0) return Colors.grey[900]!;

    // 테트로미노 타입별 색상
    const colors = [
      Colors.cyan, // I
      Colors.blue, // J
      Colors.orange, // L
      Colors.yellow, // O
      Colors.green, // S
      Colors.purple, // T
      Colors.red, // Z
    ];

    if (value > 0 && value <= colors.length) {
      return colors[value - 1];
    }

    return Colors.grey;
  }
}
