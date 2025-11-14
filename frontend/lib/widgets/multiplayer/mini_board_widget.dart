import 'package:flutter/material.dart';

/// 미니 보드 위젯 (상대방 보드 표시용)
class MiniBoardWidget extends StatelessWidget {
  final List<List<int>> board;

  const MiniBoardWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: _MiniBoardPainter(board),
          size: const Size(double.infinity, double.infinity),
          isComplex: true,
          willChange: false,
        ),
      ),
    );
  }
}

/// 미니 보드 CustomPainter
class _MiniBoardPainter extends CustomPainter {
  final List<List<int>> board;

  // 블록 색상 매핑
  static final List<Color> _blockColors = [
    Colors.transparent, // 0: 빈 칸
    Colors.cyan, // 1: I
    Colors.yellow, // 2: O
    Colors.purple, // 3: T
    Colors.green, // 4: S
    Colors.red, // 5: Z
    Colors.blue, // 6: J
    Colors.orange, // 7: L
  ];

  _MiniBoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    if (board.isEmpty) return;

    final rows = board.length;
    final cols = board[0].length;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // 배경
    final bgPaint = Paint()..color = Colors.grey[900]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 격자 및 블록 그리기
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final cellValue = board[y][x];
        final cellRect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        // 격자
        final gridPaint = Paint()
          ..color = Colors.grey[700]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawRect(cellRect, gridPaint);

        // 블록
        if (cellValue > 0 && cellValue < _blockColors.length) {
          final blockPaint = Paint()
            ..color = _blockColors[cellValue]
            ..style = PaintingStyle.fill;
          canvas.drawRect(cellRect, blockPaint);

          // 블록 테두리
          final borderPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRect(cellRect, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_MiniBoardPainter oldDelegate) {
    if (board.length != oldDelegate.board.length) return true;

    for (int i = 0; i < board.length; i++) {
      if (board[i].length != oldDelegate.board[i].length) return true;
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] != oldDelegate.board[i][j]) return true;
      }
    }
    return false;
  }
}
