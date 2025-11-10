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
    final color = GameConstants.blockColors[value] ?? Colors.transparent;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: value == 0 ? Colors.grey[800]! : Colors.black,
          width: GameConstants.borderWidth,
        ),
        boxShadow: value != 0 ? [
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
