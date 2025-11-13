import 'package:flutter/material.dart';
import '../../core/models/tetromino.dart';
import '../game/cell_widget.dart';

class MiniBlockPreview extends StatelessWidget {
  final Tetromino? tetromino;

  const MiniBlockPreview({super.key, this.tetromino});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.grey[700]!, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: AspectRatio(aspectRatio: 1, child: _buildPreview()),
    );
  }

  Widget _buildPreview() {
    if (tetromino == null) {
      return Center(
        child: Icon(Icons.block, color: Colors.grey[700], size: 20),
      );
    }

    final shape = tetromino!.shape;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 4;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (col) => CellWidget(
                  value: shape[row][col] == 1 ? tetromino!.colorCode : 0,
                  size: cellSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
