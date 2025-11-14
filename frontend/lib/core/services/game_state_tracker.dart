/// 게임 상태 변경 추적 서비스
/// Single Responsibility: 게임 상태 변경 감지만 담당
class GameStateTracker {
  int _lastScore = 0;
  int _lastLevel = 1;
  int _lastLines = 0;
  String _lastBoardHash = '';

  /// 게임 상태가 변경되었는지 확인
  bool hasChanged({
    required int score,
    required int level,
    required int lines,
    required List<List<int>> board,
  }) {
    final currentBoardHash = _generateBoardHash(board);

    final scoreChanged = _lastScore != score;
    final levelChanged = _lastLevel != level;
    final linesChanged = _lastLines != lines;
    final boardChanged = _lastBoardHash != currentBoardHash;

    final hasAnyChange =
        scoreChanged || levelChanged || linesChanged || boardChanged;

    if (hasAnyChange) {
      _lastScore = score;
      _lastLevel = level;
      _lastLines = lines;
      _lastBoardHash = currentBoardHash;
    }

    return hasAnyChange;
  }

  /// 보드 해시 생성 (변경 감지용)
  String _generateBoardHash(List<List<int>> board) {
    return board.map((row) => row.join(',')).join('|');
  }

  /// 상태 초기화
  void reset() {
    _lastScore = 0;
    _lastLevel = 1;
    _lastLines = 0;
    _lastBoardHash = '';
  }
}
