import 'package:flutter/foundation.dart';
import '../core/models/board.dart';
import '../core/models/tetromino.dart';
import '../core/models/game_engine.dart';
import '../core/constants/game_constants.dart';
import '../core/services/tetromino_generator.dart';
import '../core/services/score_calculator.dart';
import '../core/services/game_timer.dart';

enum GameState {
  idle,
  playing,
  paused,
  gameOver,
}

class GameProvider with ChangeNotifier {
  late Board _board;
  Board get board => _board;

  late GameEngine _engine;
  GameEngine get engine => _engine;

  Tetromino? _currentTetromino;
  Tetromino? get currentTetromino => _currentTetromino;

  Tetromino? _nextTetromino;
  Tetromino? get nextTetromino => _nextTetromino;

  GameState _gameState = GameState.idle;
  GameState get gameState => _gameState;

  final TetrominoGenerator _generator = TetrominoGenerator();
  final ScoreCalculator _scoreCalculator = ScoreCalculator();
  
  int get score => _scoreCalculator.score;
  int get level => _scoreCalculator.level;
  int get totalLines => _scoreCalculator.totalLines;

  final GameTimer _timer = GameTimer();

  GameProvider() {
    _board = Board();
    _engine = GameEngine(board: _board);
  }

  void startGame() {
    _board.reset();
    _scoreCalculator.reset();
    
    _generator.initialize();
    _currentTetromino = _generator.getNext();
    _nextTetromino = _generator.peekNext();
    
    _gameState = GameState.playing;
    _startFallTimer();
    
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _timer.stop();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _startFallTimer();
      notifyListeners();
    }
  }

  void restartGame() {
    _timer.stop();
    startGame();
  }

  void _startFallTimer() {
    final speed = _scoreCalculator.calculateSpeed(
      GameConstants.initialSpeed,
      GameConstants.speedDecrease,
      GameConstants.minSpeed,
    );
    _timer.start(speed, _autoFall);
  }

  void _autoFall() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    if (_engine.canMoveDown(_currentTetromino!)) {
      _currentTetromino!.moveDown();
      notifyListeners();
    } else {
      _lockCurrentTetromino();
    }
  }

  void _lockCurrentTetromino() {
    if (_currentTetromino == null) return;

    _engine.lockTetromino(_currentTetromino!);
    _clearLinesAndUpdateScore();
    _spawnNextTetromino();
  }

  void _clearLinesAndUpdateScore() {
    final clearedLines = _board.clearFullLines();
    
    if (clearedLines > 0) {
      final previousLevel = _scoreCalculator.level;
      _scoreCalculator.addLineScore(clearedLines);
      
      if (_scoreCalculator.level > previousLevel) {
        _updateSpeed();
      }
    }
  }

  void _updateSpeed() {
    if (_gameState == GameState.playing) {
      _startFallTimer();
    }
  }

  void _spawnNextTetromino() {
    _currentTetromino = _generator.getNext();
    _nextTetromino = _generator.peekNext();

    if (_currentTetromino != null && 
        !_engine.isValidPosition(_currentTetromino!)) {
      _gameOver();
    }

    notifyListeners();
  }

  void _gameOver() {
    _gameState = GameState.gameOver;
    _timer.stop();
    notifyListeners();
  }

  void moveLeft() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    if (_engine.canMoveLeft(_currentTetromino!)) {
      _currentTetromino!.moveLeft();
      notifyListeners();
    }
  }

  void moveRight() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    if (_engine.canMoveRight(_currentTetromino!)) {
      _currentTetromino!.moveRight();
      notifyListeners();
    }
  }

  void moveDown() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    if (_engine.canMoveDown(_currentTetromino!)) {
      _currentTetromino!.moveDown();
      _scoreCalculator.addSoftDropScore();
      notifyListeners();
    }
  }

  void hardDrop() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    int dropDistance = 0;
    while (_engine.canMoveDown(_currentTetromino!)) {
      _currentTetromino!.moveDown();
      dropDistance++;
    }

    _scoreCalculator.addHardDropScore(dropDistance);
    _lockCurrentTetromino();
    notifyListeners();
  }

  void rotate() {
    if (_gameState != GameState.playing || _currentTetromino == null) {
      return;
    }

    final temp = _currentTetromino!.copy();
    temp.rotateClockwise();

    if (_engine.isValidPosition(temp)) {
      _currentTetromino!.rotateClockwise();
      notifyListeners();
    } else {
      _tryWallKick(temp);
    }
  }

  void _tryWallKick(Tetromino rotated) {
    final offsets = [1, -1, 2, -2];
    
    for (final offset in offsets) {
      final temp = rotated.copy();
      temp.x += offset;
      
      if (_engine.isValidPosition(temp)) {
        _currentTetromino!.rotateClockwise();
        _currentTetromino!.x += offset;
        notifyListeners();
        return;
      }
    }
    
    final tempUp = rotated.copy();
    tempUp.y -= 1;
    if (_engine.isValidPosition(tempUp)) {
      _currentTetromino!.rotateClockwise();
      _currentTetromino!.y -= 1;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }
}
