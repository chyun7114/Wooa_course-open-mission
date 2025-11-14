import 'package:flutter/material.dart';
import 'package:frontend/core/constants/ui_constants.dart';

/// 게임 오버 오버레이
class GameOverOverlay extends StatelessWidget {
  final int score;
  final int level;

  const GameOverOverlay({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(UIConstants.extraLargeSpacing),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(UIConstants.spacing),
            border: Border.all(
              color: Colors.red,
              width: UIConstants.borderWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: UIConstants.gameOverTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.largeSpacing),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: UIConstants.gameOverScoreSize,
                ),
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              Text(
                'Level: $level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: UIConstants.gameOverLevelSize,
                ),
              ),
              const SizedBox(height: UIConstants.extraLargeSpacing),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: UIConstants.spacing,
                  ),
                ),
                child: const Text(
                  '방으로 돌아가기',
                  style: TextStyle(fontSize: UIConstants.gameOverButtonSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
