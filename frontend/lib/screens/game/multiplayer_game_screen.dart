import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/game_intent.dart';
import 'package:frontend/core/constants/game_action.dart';
import 'package:frontend/core/constants/ui_constants.dart';
import 'package:frontend/core/services/game_state_tracker.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/multiplayer_game_provider.dart';
import '../../widgets/multiplayer/my_game_area.dart';
import '../../widgets/multiplayer/opponents_area.dart';
import '../../widgets/multiplayer/game_over_overlay.dart';

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

  @override
  void initState() {
    super.initState();

    _multiplayerProvider = context.read<MultiplayerGameProvider>();
    _multiplayerProvider.initGame(
      widget.roomId,
      widget.myPlayerId,
      widget.players,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.startGame();
      gameProvider.addListener(_onGameStateChanged);

      // 초기 상태 전송
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
    context.read<GameProvider>().removeListener(_onGameStateChanged);
    super.dispose();
  }

  /// 게임 상태 변화 감지하여 멀티플레이 서버로 전송
  void _onGameStateChanged() {
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
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveLeftIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const MoveRightIntent(),
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
                            maxWidth: UIConstants.maxWidth,
                          ),
                          padding: const EdgeInsets.all(UIConstants.spacing),
                          child: Row(
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
                  if (gameProvider.gameState == GameState.gameOver)
                    GameOverOverlay(
                      score: gameProvider.score,
                      level: gameProvider.level,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
