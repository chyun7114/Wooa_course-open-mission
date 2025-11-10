class ScoreCalculator {
  int _score = 0;
  int get score => _score;
  
  int _level = 1;
  int get level => _level;
  
  int _totalLines = 0;
  int get totalLines => _totalLines;
  
  int addLineScore(int clearedLines) {
    if (clearedLines <= 0) return 0;
    
    final scores = [0, 100, 300, 500, 800];
    final baseScore = scores[clearedLines.clamp(0, 4)];
    final earnedScore = baseScore * _level;
    
    _score += earnedScore;
    _totalLines += clearedLines;
    
    _checkLevelUp();
    
    return earnedScore;
  }
  
  void addSoftDropScore() {
    _score += 1;
  }
  
  void addHardDropScore(int distance) {
    _score += distance * 2;
  }
  
  void _checkLevelUp() {
    final newLevel = (_totalLines ~/ 10) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
  }
  
  void reset() {
    _score = 0;
    _level = 1;
    _totalLines = 0;
  }
  
  int calculateSpeed(int initialSpeed, int speedDecrease, int minSpeed) {
    return (initialSpeed - ((_level - 1) * speedDecrease))
        .clamp(minSpeed, initialSpeed);
  }
}
