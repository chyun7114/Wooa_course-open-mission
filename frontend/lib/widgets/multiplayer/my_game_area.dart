import 'package:flutter/material.dart';
import 'package:frontend/core/constants/ui_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/multiplayer_game_provider.dart';
import '../game/board_widget.dart';
import 'mini_block_preview.dart';
import 'mini_game_info.dart';

/// 내 게임 영역 위젯
class MyGameArea extends StatelessWidget {
  const MyGameArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplayerGameProvider>(
      builder: (context, multiProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(UIConstants.spacing),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(UIConstants.borderRadius),
                border: Border.all(
                  color: Colors.blue,
                  width: UIConstants.borderWidth,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  if (multiProvider.incomingAttackLines > 0)
                    _buildAttackWarning(multiProvider.incomingAttackLines),
                  const SizedBox(height: UIConstants.smallSpacing),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BlockPreviewPanel(
                          label: 'HOLD',
                          tetrominoGetter: (provider) => provider.holdTetromino,
                        ),
                        const SizedBox(width: UIConstants.smallSpacing),
                        const Expanded(
                          child: _GameBoard(),
                        ),
                        const SizedBox(width: UIConstants.smallSpacing),
                        const _NextAndScorePanel(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.smallSpacing),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: Colors.blue),
          SizedBox(width: UIConstants.smallSpacing),
          Text(
            'MY GAME',
            style: TextStyle(
              color: Colors.blue,
              fontSize: UIConstants.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttackWarning(int lines) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '공격받음! +$lines 줄',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 블록 미리보기 패널 (HOLD/NEXT 공통)
class _BlockPreviewPanel extends StatelessWidget {
  final String label;
  final dynamic Function(GameProvider) tetrominoGetter;

  const _BlockPreviewPanel({
    required this.label,
    required this.tetrominoGetter,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: UIConstants.previewSize,
        minWidth: 60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: UIConstants.labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.smallSpacing),
          Container(
            height: UIConstants.previewSize,
            width: UIConstants.previewSize,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                UIConstants.smallBorderRadius,
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
}

/// 게임 보드
class _GameBoard extends StatelessWidget {
  const _GameBoard();

  @override
  Widget build(BuildContext context) {
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
}

/// NEXT 및 점수 패널
class _NextAndScorePanel extends StatelessWidget {
  const _NextAndScorePanel();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: UIConstants.previewSize,
        minWidth: 60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: _buildNextPreview()),
          const SizedBox(height: UIConstants.smallSpacing),
          Flexible(child: _buildScoreInfo()),
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
            fontSize: UIConstants.labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.smallSpacing),
        Container(
          height: UIConstants.previewSize,
          width: UIConstants.previewSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
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
}
