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

    return LayoutBuilder(
      builder: (context, constraints) {
        // 사용 가능한 공간 확인
        final hasFiniteWidth = constraints.maxWidth.isFinite;
        final hasFiniteHeight = constraints.maxHeight.isFinite;

        // 멀티플레이: 제약 조건이 있는 경우 (Expanded 내부)
        if (hasFiniteWidth && hasFiniteHeight) {
          final availableWidth = constraints.maxWidth - 4; // border 제외
          final availableHeight = constraints.maxHeight - 4; // border 제외

          final cellWidth = availableWidth / board.width;
          final cellHeight = availableHeight / board.height;

          // 세로 높이를 최대한 활용하도록 cellHeight 우선 사용
          // 단, 가로가 넘치지 않도록 제한
          final cellSize = cellHeight * board.width <= availableWidth
              ? cellHeight
              : cellWidth;

          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                board.height,
                (y) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    board.width,
                    (x) => CellWidget(value: grid[y][x], size: cellSize),
                  ),
                ),
              ),
            ),
          );
        }

        // 싱글플레이: 제약 조건이 없는 경우 고정 크기 사용
        const double cellSize = 25.0;

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
                  (x) => CellWidget(value: grid[y][x], size: cellSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
