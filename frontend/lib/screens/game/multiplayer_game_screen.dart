import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/game_intent.dart';
import 'package:frontend/core/constants/game_action.dart';
import 'package:frontend/core/constants/ui_constants.dart';
import 'package:frontend/core/services/game_state_tracker.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/multiplayer_game_provider.dart';
import '../../providers/room_waiting_provider.dart';
import '../../widgets/multiplayer/my_game_area.dart';
import '../../widgets/multiplayer/opponents_area.dart';

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
  final GameStateTracker _stateTracker = GameStateTracker();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    debugPrint('🎮 MultiplayerGameScreen initState');

    _multiplayerProvider = context.read<MultiplayerGameProvider>();
    _multiplayerProvider.initGame(
      widget.roomId,
      widget.myPlayerId,
      widget.players,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final gameProvider = context.read<GameProvider>();
      gameProvider.addListener(_onGameStateChanged);

      // 멀티플레이 게임 시작
      // (RoomWaitingScreen에서 gameStarted 이벤트를 받고 이 화면으로 전환됨)
      debugPrint('🎮 Starting multiplayer game');
      gameProvider.startGame(isMultiplayer: true);

      // 초기 게임 상태 전송
      _multiplayerProvider.updateGameState(
        score: gameProvider.score,
        level: gameProvider.level,
        linesCleared: gameProvider.totalLines,
        board: gameProvider.board.grid,
      );
    });
  }

  @override
  void dispose() {
    _isDisposed = true;

    try {
      final gameProvider = context.read<GameProvider>();
      gameProvider.removeListener(_onGameStateChanged);

      // 게임 타이머 정리
      if (gameProvider.gameState == GameState.playing) {
        gameProvider.pauseGame();
      }
    } catch (e) {
      // Context가 이미 dispose된 경우 무시
    }

    // 상태 트래커 초기화
    _stateTracker.reset();

    super.dispose();
  }

  /// 게임 상태 변화 감지하여 멀티플레이 서버로 전송
  void _onGameStateChanged() {
    if (_isDisposed || !mounted) return;

    final gameProvider = context.read<GameProvider>();

    // GameStateTracker로 변경 감지
    if (_stateTracker.hasChanged(
      score: gameProvider.score,
      level: gameProvider.level,
      lines: gameProvider.totalLines,
      board: gameProvider.board.grid,
    )) {
      _multiplayerProvider.updateGameState(
        score: gameProvider.score,
        level: gameProvider.level,
        linesCleared: gameProvider.totalLines,
        board: gameProvider.board.grid,
      );
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
    return Consumer2<GameProvider, MultiplayerGameProvider>(
      builder: (context, gameProvider, multiProvider, child) {
        // 게임 종료 시 순위 화면 표시
        if (multiProvider.gameState?.isGameEnded == true &&
            multiProvider.gameState?.finalRanking != null) {
          return _buildRankingOverlay(
            context,
            multiProvider.gameState!.finalRanking!,
          );
        }

        return Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveLeftIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowRight):
                const MoveRightIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
            LogicalKeySet(LogicalKeyboardKey.arrowUp): const RotateIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): const HardDropIntent(),
            LogicalKeySet(LogicalKeyboardKey.keyC): const HoldIntent(),
            LogicalKeySet(LogicalKeyboardKey.shiftLeft): const HoldIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              MoveLeftIntent: MoveLeftAction(context),
              MoveRightIntent: MoveRightAction(context),
              MoveDownIntent: MoveDownAction(context),
              RotateIntent: RotateAction(context),
              HardDropIntent: HardDropAction(context),
              HoldIntent: HoldAction(context),
            },
            child: Focus(
              autofocus: true,
              child: Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.black,
                    body: SafeArea(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: UIConstants.maxWidth,
                          ),
                          padding: const EdgeInsets.all(UIConstants.spacing),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                flex: UIConstants.myGameFlex,
                                child: MyGameArea(),
                              ),
                              const SizedBox(width: UIConstants.spacing),
                              Expanded(
                                flex: UIConstants.opponentsFlex,
                                child: OpponentsArea(
                                  myPlayerId: widget.myPlayerId,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (gameProvider.gameState == GameState.gameOver &&
                      !(multiProvider.gameState?.isGameEnded ?? false))
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'GAME OVER',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '점수: ${gameProvider.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              '다른 플레이어의 게임이 진행 중입니다...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankingOverlay(
    BuildContext context,
    List<PlayerGameState> ranking,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆 최종 순위 🏆',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ranking.length,
                  itemBuilder: (context, index) {
                    final player = ranking[index];
                    final isMe = player.playerId == widget.myPlayerId;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[900] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: isMe
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getRankEmoji(player.rank),
                            style: const TextStyle(fontSize: 28),
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
                                    fontSize: 18,
                                    fontWeight: isMe
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '점수: ${player.score} | Lv.${player.level} | 라인: ${player.linesCleared}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _returnToRoom(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '방으로 돌아가기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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

  void _returnToRoom(BuildContext context) {
    try {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.gameState == GameState.playing) {
        gameProvider.pauseGame();
      }
      gameProvider.restartGame();
    } catch (e) {
      debugPrint('GameProvider 정리 오류: $e');
    }

    try {
      final roomProvider = context.read<RoomWaitingProvider>();
      roomProvider.resetGameStarted();
    } catch (e) {
      debugPrint('RoomWaitingProvider 없음 또는 오류: $e');
    }

    Navigator.of(context).pop();
  }
}
