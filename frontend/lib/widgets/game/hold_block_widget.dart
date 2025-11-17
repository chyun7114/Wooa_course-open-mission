import 'package:flutter/material.dart';
import '../../core/models/tetromino.dart';
import 'cell_widget.dart';

class HoldBlockWidget extends StatelessWidget {
  final Tetromino? holdTetromino;

  const HoldBlockWidget({super.key, this.holdTetromino});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'HOLD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final shape = holdTetromino?.shape;

    return SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            4,
            (row) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                4,
                (col) => CellWidget(
                  value: shape != null && shape[row][col] == 1
                      ? holdTetromino!.colorCode
                      : 0,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
