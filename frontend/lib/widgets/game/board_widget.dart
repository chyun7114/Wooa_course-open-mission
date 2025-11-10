import 'package:flutter/material.dart';
import '../../core/models/board.dart';
import '../../core/models/tetromino.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final Tetromino? currentTetromino;
  final Tetromino? ghostTetromino;

  const BoardWidget({
    super.key,
    required this.board,
    this.currentTetromino,
    this.ghostTetromino,
  });

  List<List<int>> _getMergedGrid() {
    final merged = List.generate(
      board.height,
      (y) => List<int>.from(board.grid[y]),
    );

    // 고스트 블록 먼저 그리기 (투명하게)
    if (ghostTetromino != null) {
      for (final pos in ghostTetromino!.positions) {
        if (board.isInside(pos.x, pos.y) && merged[pos.y][pos.x] == 0) {
          merged[pos.y][pos.x] = -ghostTetromino!.colorCode; // 음수로 고스트 표시
        }
      }
    }

    // 현재 블록 그리기
    if (currentTetromino != null) {
      for (final pos in currentTetromino!.positions) {
        if (board.isInside(pos.x, pos.y)) {
          merged[pos.y][pos.x] = currentTetromino!.colorCode;
        }
      }
    }

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final grid = _getMergedGrid();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          board.height,
          (y) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              board.width,
              (x) => CellWidget(value: grid[y][x]),
            ),
          ),
        ),
      ),
    );
  }
}
