import 'package:flutter/material.dart';
import '../core/constants/game_constants.dart';

class CellWidget extends StatelessWidget {
  final int value;
  final double size;

  const CellWidget({
    super.key,
    required this.value,
    this.size = GameConstants.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final isGhost = value < 0;
    final colorCode = isGhost ? -value : value;
    final color = GameConstants.blockColors[colorCode] ?? Colors.transparent;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isGhost ? color.withOpacity(0.3) : color,
        border: Border.all(
          color: value == 0 
            ? Colors.grey[800]! 
            : isGhost 
              ? color.withOpacity(0.5)
              : Colors.black,
          width: GameConstants.borderWidth,
        ),
        boxShadow: value != 0 && !isGhost ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ] : null,
      ),
    );
  }
}
