import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game/board_widget.dart';
import '../widgets/multiplayer/opponent_board.dart';
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
  final List<String> playerIds;

  const MultiplayerGameScreen({
    super.key,
    required this.roomId,
    required this.playerIds,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startGame();
    });
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
    return Container(
      padding: const EdgeInsets.all(_UIConstants.spacing),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(_UIConstants.borderRadius),
        border: Border.all(color: Colors.blue, width: _UIConstants.borderWidth),
      ),
      child: Column(
        children: [
          _buildMyGameTitle(),
          const SizedBox(height: _UIConstants.spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBlockPreviewPanel(
                  'HOLD',
                  (provider) => provider.holdTetromino,
                ),
                const SizedBox(width: _UIConstants.spacing),
                Expanded(child: _buildGameBoard()),
                const SizedBox(width: _UIConstants.spacing),
                _buildNextAndScorePanel(),
              ],
            ),
          ),
        ],
      ),
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
    final opponents = _getDummyOpponents();

    return Column(
      children: [
        Expanded(child: _buildOpponentRow(opponents, 0, 3)),
        const SizedBox(height: 12),
        Expanded(child: _buildOpponentRow(opponents, 3, 7)),
      ],
    );
  }

  Widget _buildOpponentRow(
    List<_OpponentData> opponents,
    int startIndex,
    int endIndex,
  ) {
    return Row(
      children: [
        for (int i = startIndex; i < endIndex && i < opponents.length; i++) ...[
          if (i > startIndex) const SizedBox(width: 12),
          Expanded(
            child: OpponentBoard(
              playerName: opponents[i].name,
              board: opponents[i].board,
              isAlive: opponents[i].isAlive,
              score: opponents[i].score,
            ),
          ),
        ],
      ],
    );
  }

  List<_OpponentData> _getDummyOpponents() {
    return List.generate(7, (index) => _OpponentData.dummy(index));
  }
}

// 더미 데이터 모델
class _OpponentData {
  final String name;
  final List<List<int>> board;
  final bool isAlive;
  final int score;

  _OpponentData({
    required this.name,
    required this.board,
    required this.isAlive,
    required this.score,
  });

  factory _OpponentData.dummy(int index) {
    final isAlive = index != 2 && index != 5; // Player 3, 6은 죽은 상태
    final board = _generateDummyBoard(index, isAlive);

    return _OpponentData(
      name: 'Player ${index + 1}',
      board: board,
      isAlive: isAlive,
      score: (index + 1) * 1000,
    );
  }

  static List<List<int>> _generateDummyBoard(int seed, bool hasBlocks) {
    final board = List.generate(20, (_) => List.filled(10, 0));

    if (!hasBlocks) return board;

    // 하단부에 랜덤하게 블록 배치
    for (int row = 15; row < 20; row++) {
      for (int col = 0; col < 10; col++) {
        if ((row + col + seed) % 3 == 0) {
          board[row][col] = ((row + col) % 7) + 1;
        }
      }
    }

    return board;
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
