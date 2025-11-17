import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/ranking_provider.dart';
import '../../widgets/game/board_widget.dart';
import '../../widgets/game/next_block_widget.dart';
import '../../widgets/game/hold_block_widget.dart';
import '../../widgets/game/game_info_widget.dart';
import '../../widgets/game/controls_guide_widget.dart';
import '../../widgets/game/game_controls_widget.dart';
import '../../widgets/game/ranking_panel_widget.dart';
import '../game_mode_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _rankingSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rankingProvider = context.read<RankingProvider>();
      rankingProvider.fetchMyRanking();
      rankingProvider.fetchTopRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<GameProvider, RankingProvider>(
        builder: (context, gameProvider, rankingProvider, child) {
          if (gameProvider.gameState == GameState.gameOver &&
              !_rankingSubmitted &&
              gameProvider.score > 0) {
            _submitRanking(gameProvider.score);
          }

          return Stack(
            children: [
              _buildGameContent(context, gameProvider, rankingProvider),
              GameControlsWidget(
                onMoveLeft: gameProvider.moveLeft,
                onMoveRight: gameProvider.moveRight,
                onMoveDown: gameProvider.moveDown,
                onRotate: gameProvider.rotate,
                onHardDrop: gameProvider.hardDrop,
                onHold: gameProvider.hold,
                onStart: () {
                  if (gameProvider.gameState == GameState.idle) {
                    gameProvider.startGame();
                  }
                },
                onPause: () {
                  if (gameProvider.gameState == GameState.playing) {
                    gameProvider.pauseGame();
                  } else if (gameProvider.gameState == GameState.paused) {
                    gameProvider.resumeGame();
                  }
                },
              ),
              if (gameProvider.gameState == GameState.idle)
                _buildStartOverlay(context, gameProvider),
              if (gameProvider.gameState == GameState.paused)
                _buildPausedOverlay(context, gameProvider),
              if (gameProvider.gameState == GameState.gameOver)
                _buildGameOverOverlay(context, gameProvider),
            ],
          );
        },
      ),
    );
  }

  void _submitRanking(int score) {
    _rankingSubmitted = true;
    final rankingProvider = context.read<RankingProvider>();
    rankingProvider.submitScore(score);
  }

  Widget _buildGameContent(
    BuildContext context,
    GameProvider gameProvider,
    RankingProvider rankingProvider,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HoldBlockWidget(holdTetromino: gameProvider.holdTetromino),
                  const SizedBox(height: 20),
                  const ControlsGuideWidget(),
                ],
              ),
              const SizedBox(width: 40),
              BoardWidget(
                board: gameProvider.board,
                currentTetromino: gameProvider.currentTetromino,
                ghostTetromino: gameProvider.ghostTetromino,
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  NextBlockWidget(nextTetromino: gameProvider.nextTetromino),
                  const SizedBox(height: 20),
                  GameInfoWidget(
                    score: gameProvider.score,
                    level: gameProvider.level,
                    lines: gameProvider.totalLines,
                    bestScore: rankingProvider.myRanking?.score,
                  ),
                ],
              ),
              const SizedBox(width: 40),
              const RankingPanelWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOverlay(BuildContext context, GameProvider gameProvider) {
    return _buildOverlay(
      context,
      title: 'TETRIS',
      message: 'Press ENTER to Start',
      onTap: gameProvider.startGame,
      showRestartButton: false,
    );
  }

  Widget _buildPausedOverlay(BuildContext context, GameProvider gameProvider) {
    return _buildOverlay(
      context,
      title: 'PAUSED',
      message: 'Press P to Resume',
      onTap: gameProvider.resumeGame,
      showResumeButton: true,
      showRestartButton: true,
      showMenuButton: true,
      onResume: gameProvider.resumeGame,
      onRestart: gameProvider.restartGame,
      onMenu: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameModeScreen()),
        );
      },
    );
  }

  Widget _buildGameOverOverlay(
    BuildContext context,
    GameProvider gameProvider,
  ) {
    return _buildOverlay(
      context,
      title: 'GAME OVER',
      message: 'Score: ${gameProvider.score}',
      onTap: () {
        _rankingSubmitted = false; // 재시작 시 초기화
        gameProvider.restartGame();
      },
      showRestartButton: true,
      showMenuButton: true,
      onRestart: () {
        _rankingSubmitted = false; // 재시작 시 초기화
        gameProvider.restartGame();
      },
      onMenu: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameModeScreen()),
        );
      },
    );
  }

  Widget _buildOverlay(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTap,
    bool showResumeButton = false,
    bool showRestartButton = false,
    bool showMenuButton = false,
    VoidCallback? onResume,
    VoidCallback? onRestart,
    VoidCallback? onMenu,
  }) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showResumeButton)
                  ElevatedButton(
                    onPressed: onResume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text(
                      'RESUME GAME',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                if (showResumeButton && showRestartButton)
                  const SizedBox(width: 20),
                if (showRestartButton)
                  ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text(
                      'RESTART GAME',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                if (showMenuButton && showRestartButton)
                  const SizedBox(width: 20),
                if (showMenuButton)
                  ElevatedButton(
                    onPressed: onMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: const Text(
                      'MENU',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
