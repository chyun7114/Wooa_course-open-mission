import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/multiplayer_game_provider.dart';
import '../widgets/game/board_widget.dart';
import '../widgets/multiplayer/mini_block_preview.dart';
import '../widgets/multiplayer/mini_game_info.dart';

// UI 상수
class _UIConstants {
  static const double maxWidth = 1600;
  static const double spacing = 16;
  static const double smallSpacing = 8;
  static const double largeSpacing = 24;
  static const double extraLargeSpacing = 32;

  static const double previewSize = 100;
  static const double borderWidth = 3;
  static const double borderRadius = 12;
  static const double smallBorderRadius = 8;

  static const double titleFontSize = 20;
  static const double labelFontSize = 12;
  static const double gameOverTitleSize = 48;
  static const double gameOverScoreSize = 24;
  static const double gameOverLevelSize = 20;
  static const double gameOverButtonSize = 18;

  static const int myGameFlex = 4;
  static const int opponentsFlex = 6;
}

class MultiplayerGameScreen extends StatefulWidget {
  final String roomId;
  final String myPlayerId;
  final List<Map<String, dynamic>> players;

  const MultiplayerGameScreen({
    super.key,
    required this.roomId,
    required this.myPlayerId,
    required this.players,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late MultiplayerGameProvider _multiplayerProvider;

  // 이전 상태 저장 (변경 감지용)
  int _lastScore = 0;
  int _lastLevel = 1;
  int _lastLines = 0;
  String _lastBoardHash = '';

  @override
  void initState() {
    super.initState();

    // MultiplayerGameProvider 초기화
    _multiplayerProvider = context.read<MultiplayerGameProvider>();
    _multiplayerProvider.initGame(
      widget.roomId,
      widget.myPlayerId,
      widget.players,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.startGame();

      // 초기 보드 상태 전송
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _multiplayerProvider.updateGameState(
            score: gameProvider.score,
            level: gameProvider.level,
            linesCleared: gameProvider.totalLines,
            board: gameProvider.board.grid,
          );
          print('🚀 초기 보드 전송 완료');
        }
      });

      // GameProvider 변화 리스닝
      gameProvider.addListener(_onGameStateChanged);
    });
  }

  @override
  void dispose() {
    context.read<GameProvider>().removeListener(_onGameStateChanged);
    super.dispose();
  }

  /// 게임 상태 변화 감지하여 멀티플레이 서버로 전송
  void _onGameStateChanged() {
    final gameProvider = context.read<GameProvider>();

    // 보드 해시 생성 (간단한 문자열 변환)
    final currentBoardHash = gameProvider.board.grid
        .map((row) => row.join(','))
        .join('|');

    // 변경 감지
    final scoreChanged = _lastScore != gameProvider.score;
    final levelChanged = _lastLevel != gameProvider.level;
    final linesChanged = _lastLines != gameProvider.totalLines;
    final boardChanged = _lastBoardHash != currentBoardHash;

    // 변경된 것이 있을 때만 전송
    if (scoreChanged || levelChanged || linesChanged || boardChanged) {
      print(
        '🎮 상태 변경 감지: score=$scoreChanged, level=$levelChanged, lines=$linesChanged, board=$boardChanged',
      );

      _multiplayerProvider.updateGameState(
        score: gameProvider.score,
        level: gameProvider.level,
        linesCleared: gameProvider.totalLines,
        board: gameProvider.board.grid, // 항상 보드 전송
      );

      print(
        '📤 보드 전송: ${gameProvider.board.grid.length}x${gameProvider.board.grid[0].length}',
      );

      // 상태 업데이트
      _lastScore = gameProvider.score;
      _lastLevel = gameProvider.level;
      _lastLines = gameProvider.totalLines;
      _lastBoardHash = currentBoardHash;
    }

    // 게임 오버 시
    if (gameProvider.gameState == GameState.gameOver) {
      final myState = _multiplayerProvider.myPlayerState;
      if (myState != null && myState.isAlive) {
        _multiplayerProvider.gameOver();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _MoveLeftIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const _MoveRightIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const _MoveDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const _RotateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const _HardDropIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyC): const _HoldIntent(),
        LogicalKeySet(LogicalKeyboardKey.shiftLeft): const _HoldIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _MoveLeftIntent: _MoveLeftAction(context),
          _MoveRightIntent: _MoveRightAction(context),
          _MoveDownIntent: _MoveDownAction(context),
          _RotateIntent: _RotateAction(context),
          _HardDropIntent: _HardDropAction(context),
          _HoldIntent: _HoldAction(context),
        },
        child: Focus(
          autofocus: true,
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.black,
                    body: SafeArea(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: _UIConstants.maxWidth,
                          ),
                          padding: const EdgeInsets.all(_UIConstants.spacing),
                          child: Row(
                            children: [
                              // 좌측: 내 게임 화면
                              Expanded(
                                flex: _UIConstants.myGameFlex,
                                child: _buildMyGameArea(),
                              ),
                              const SizedBox(width: _UIConstants.spacing),
                              // 우측: 상대 게임 화면들
                              Expanded(
                                flex: _UIConstants.opponentsFlex,
                                child: _buildOpponentsArea(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 게임 오버 오버레이
                  if (gameProvider.gameState == GameState.gameOver)
                    _buildGameOverOverlay(gameProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(GameProvider gameProvider) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(_UIConstants.extraLargeSpacing),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(_UIConstants.spacing),
            border: Border.all(
              color: Colors.red,
              width: _UIConstants.borderWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: _UIConstants.gameOverTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _UIConstants.largeSpacing),
              Text(
                'Score: ${gameProvider.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: _UIConstants.gameOverScoreSize,
                ),
              ),
              const SizedBox(height: _UIConstants.smallSpacing),
              Text(
                'Level: ${gameProvider.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: _UIConstants.gameOverLevelSize,
                ),
              ),
              const SizedBox(height: _UIConstants.extraLargeSpacing),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: _UIConstants.spacing,
                  ),
                ),
                child: const Text(
                  '방으로 돌아가기',
                  style: TextStyle(fontSize: _UIConstants.gameOverButtonSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyGameArea() {
    return Consumer<MultiplayerGameProvider>(
      builder: (context, multiProvider, child) {
        return Container(
          padding: const EdgeInsets.all(_UIConstants.spacing),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(_UIConstants.borderRadius),
            border: Border.all(
              color: Colors.blue,
              width: _UIConstants.borderWidth,
            ),
          ),
          child: Column(
            children: [
              _buildMyGameTitle(),
              // 공격 받는 표시
              if (multiProvider.incomingAttackLines > 0)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '공격받음! +${multiProvider.incomingAttackLines} 줄',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: _UIConstants.smallSpacing),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBlockPreviewPanel(
                      'HOLD',
                      (provider) => provider.holdTetromino,
                    ),
                    const SizedBox(width: _UIConstants.smallSpacing),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 0.5, // 테트리스 보드 비율
                          child: _buildGameBoard(),
                        ),
                      ),
                    ),
                    const SizedBox(width: _UIConstants.smallSpacing),
                    _buildNextAndScorePanel(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyGameTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: _UIConstants.smallSpacing),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: Colors.blue),
          SizedBox(width: _UIConstants.smallSpacing),
          Text(
            'MY GAME',
            style: TextStyle(
              color: Colors.blue,
              fontSize: _UIConstants.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockPreviewPanel(
    String label,
    dynamic Function(GameProvider) tetrominoGetter,
  ) {
    return SizedBox(
      width: _UIConstants.previewSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: _UIConstants.labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: _UIConstants.smallSpacing),
          Container(
            height: _UIConstants.previewSize,
            width: _UIConstants.previewSize,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                _UIConstants.smallBorderRadius,
              ),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return MiniBlockPreview(
                  tetromino: tetrominoGetter(gameProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return BoardWidget(
          board: gameProvider.board,
          currentTetromino: gameProvider.currentTetromino,
          ghostTetromino: gameProvider.ghostTetromino,
        );
      },
    );
  }

  Widget _buildNextAndScorePanel() {
    return SizedBox(
      width: _UIConstants.previewSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNextPreview(),
          const SizedBox(height: _UIConstants.largeSpacing),
          _buildScoreInfo(),
        ],
      ),
    );
  }

  Widget _buildNextPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NEXT',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: _UIConstants.labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: _UIConstants.smallSpacing),
        Container(
          height: _UIConstants.previewSize,
          width: _UIConstants.previewSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(_UIConstants.smallBorderRadius),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return MiniBlockPreview(tetromino: gameProvider.nextTetromino);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScoreInfo() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return MiniGameInfo(
          score: gameProvider.score,
          level: gameProvider.level,
          lines: gameProvider.totalLines,
        );
      },
    );
  }

  Widget _buildOpponentsArea() {
    return Consumer<MultiplayerGameProvider>(
      builder: (context, multiProvider, child) {
        if (multiProvider.gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 게임 종료 시 순위 화면
        if (multiProvider.gameState!.isGameEnded &&
            multiProvider.gameState!.finalRanking != null) {
          return _buildRankingScreen(multiProvider.gameState!.finalRanking!);
        }

        // 상대방 목록
        final opponents = multiProvider.gameState!.players.values
            .where((p) => p.playerId != widget.myPlayerId)
            .toList();

        return Container(
          padding: const EdgeInsets.all(_UIConstants.spacing),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(_UIConstants.borderRadius),
            border: Border.all(color: Colors.grey[700]!, width: 2),
          ),
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '상대방 (${opponents.length}명)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _UIConstants.spacing),
              // 상대방 그리드
              Expanded(
                child: opponents.isEmpty
                    ? const Center(
                        child: Text(
                          '상대방이 없습니다',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: opponents.length,
                        itemBuilder: (context, index) {
                          return _buildOpponentCard(opponents[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpponentCard(PlayerGameState opponent) {
    // 디버그: 보드 상태 확인
    if (opponent.board != null) {
      print(
        '🎨 렌더링: ${opponent.nickname} 보드 크기 ${opponent.board!.length}x${opponent.board![0].length}',
      );
    } else {
      print('⚠️ ${opponent.nickname} 보드 없음');
    }

    return Container(
      decoration: BoxDecoration(
        color: opponent.isAlive ? Colors.grey[850] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: opponent.isAlive
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 플레이어 정보
          Row(
            children: [
              Icon(
                opponent.isAlive ? Icons.check_circle : Icons.cancel,
                color: opponent.isAlive ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  opponent.nickname,
                  style: TextStyle(
                    color: opponent.isAlive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!opponent.isAlive && opponent.rank > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
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
            ),
          ],
          const SizedBox(height: 8),

          // 미니 보드 (있으면 표시)
          if (opponent.board != null && opponent.board!.isNotEmpty)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildMiniBoard(opponent.board!),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
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
              ),
            ),

          const SizedBox(height: 8),
          // 게임 정보
          _buildStatRow(Icons.stars, '점수', opponent.score.toString()),
          _buildStatRow(Icons.trending_up, '레벨', 'Lv.${opponent.level}'),
          _buildStatRow(
            Icons.format_list_numbered,
            '라인',
            '${opponent.linesCleared}',
          ),
        ],
      ),
    );
  }

  // 미니 보드 위젯
  Widget _buildMiniBoard(List<List<int>> board) {
    return CustomPaint(painter: _MiniBoardPainter(board));
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingScreen(List<PlayerGameState> ranking) {
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
                final isMe = player.playerId == widget.myPlayerId;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[900] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: isMe
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
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
                                fontWeight: isMe
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              '점수: ${player.score} | Lv.${player.level}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
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

// 미니 보드 Painter
class _MiniBoardPainter extends CustomPainter {
  final List<List<int>> board;

  _MiniBoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final rows = board.length;
    final cols = board.isNotEmpty ? board[0].length : 10;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // 배경 그리기 (디버그용)
    final bgPaint = Paint()..color = Colors.grey[900]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 블록 색상 매핑
    final colors = [
      Colors.transparent, // 0: 빈 칸
      Colors.cyan, // 1: I
      Colors.yellow, // 2: O
      Colors.purple, // 3: T
      Colors.green, // 4: S
      Colors.red, // 5: Z
      Colors.blue, // 6: J
      Colors.orange, // 7: L
    ];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final cellValue = board[y][x];

        // 격자 그리기
        final gridPaint = Paint()
          ..color = Colors.grey[800]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3;

        final cellRect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(cellRect, gridPaint);

        // 블록 그리기
        if (cellValue > 0 && cellValue < colors.length) {
          final paint = Paint()
            ..color = colors[cellValue]
            ..style = PaintingStyle.fill;

          canvas.drawRect(cellRect, paint);

          // 블록 테두리
          final borderPaint = Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          canvas.drawRect(cellRect, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_MiniBoardPainter oldDelegate) {
    // 보드 내용이 실제로 변경되었을 때만 다시 그리기
    if (board.length != oldDelegate.board.length) return true;

    for (int i = 0; i < board.length; i++) {
      if (board[i].length != oldDelegate.board[i].length) return true;
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] != oldDelegate.board[i][j]) return true;
      }
    }

    return false;
  }
}

// Intent 클래스들
class _MoveLeftIntent extends Intent {
  const _MoveLeftIntent();
}

class _MoveRightIntent extends Intent {
  const _MoveRightIntent();
}

class _MoveDownIntent extends Intent {
  const _MoveDownIntent();
}

class _RotateIntent extends Intent {
  const _RotateIntent();
}

class _HardDropIntent extends Intent {
  const _HardDropIntent();
}

class _HoldIntent extends Intent {
  const _HoldIntent();
}

// Generic Action 클래스
class _GameAction<T extends Intent> extends Action<T> {
  _GameAction(this.context, this.callback);

  final BuildContext context;
  final void Function(GameProvider) callback;

  @override
  void invoke(T intent) {
    callback(context.read<GameProvider>());
  }
}

// Action 편의 생성자들
class _MoveLeftAction extends _GameAction<_MoveLeftIntent> {
  _MoveLeftAction(BuildContext context)
    : super(context, (provider) => provider.moveLeft());
}

class _MoveRightAction extends _GameAction<_MoveRightIntent> {
  _MoveRightAction(BuildContext context)
    : super(context, (provider) => provider.moveRight());
}

class _MoveDownAction extends _GameAction<_MoveDownIntent> {
  _MoveDownAction(BuildContext context)
    : super(context, (provider) => provider.moveDown());
}

class _RotateAction extends _GameAction<_RotateIntent> {
  _RotateAction(BuildContext context)
    : super(context, (provider) => provider.rotate());
}

class _HardDropAction extends _GameAction<_HardDropIntent> {
  _HardDropAction(BuildContext context)
    : super(context, (provider) => provider.hardDrop());
}

class _HoldAction extends _GameAction<_HoldIntent> {
  _HoldAction(BuildContext context)
    : super(context, (provider) => provider.hold());
}
