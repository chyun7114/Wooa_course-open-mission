import 'package:flutter/foundation.dart';
import '../core/models/board.dart';
import '../core/models/tetromino.dart';
import '../core/models/game_engine.dart';
import '../core/constants/game_constants.dart';
import '../core/services/tetromino_generator.dart';
import '../core/services/score_calculator.dart';
import '../core/services/game_timer.dart';

enum GameState { idle, playing, paused, gameOver }

class GameProvider with ChangeNotifier {
  late Board _board;
  Board get board => _board;

  late GameEngine _engine;
  GameEngine get engine => _engine;

  Tetromino? _currentTetromino;
  Tetromino? get currentTetromino => _currentTetromino;

  Tetromino? _nextTetromino;
  Tetromino? get nextTetromino => _nextTetromino;

  Tetromino? _holdTetromino;
  Tetromino? get holdTetromino => _holdTetromino;

  bool _holdUsed = false;
  bool _isMultiplayerMode = false;
  bool _isGameEnded = false;
  bool _isDisposed = false;

  bool get isMultiplayerMode => _isMultiplayerMode;
  bool get isGameEnded => _isGameEnded;

  Tetromino? get ghostTetromino {
    if (_currentTetromino == null || _gameState != GameState.playing) {
      return null;
    }

    final ghost = _currentTetromino!.copy();
    while (_engine.canMoveDown(ghost)) {
      ghost.moveDown();
    }
    return ghost;
  }

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

  void startGame({bool isMultiplayer = false}) {
    // 기존 타이머 정리
    _timer.stop();

    // 모든 상태 완전 초기화
    _isMultiplayerMode = isMultiplayer;
    _isGameEnded = false;
    _isDisposed = false;
    _gameState = GameState.idle;

    // 보드 및 점수 초기화
    _board.reset();
    _scoreCalculator.reset();

    // 테트로미노 초기화
    _generator.initialize();
    _currentTetromino = _generator.getNext();
    _nextTetromino = _generator.peekNext();
    _holdTetromino = null;
    _holdUsed = false;

    // 게임 시작
    _gameState = GameState.playing;
    _startFallTimer();

    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _timer.stop();
      _safeNotifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _startFallTimer();
      _safeNotifyListeners();
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
      _safeNotifyListeners();
    } else {
      _lockCurrentTetromino();
    }
  }

  void _lockCurrentTetromino() {
    if (_currentTetromino == null) return;

    _engine.lockTetromino(_currentTetromino!);
    _clearLinesAndUpdateScore();
    _holdUsed = false;
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

    _safeNotifyListeners();
  }

  void _gameOver() {
    _gameState = GameState.gameOver;
    _timer.stop();
    _safeNotifyListeners();
  }

  // 멀티플레이 게임 종료 (순위 화면 표시용)
  void endMultiplayerGame() {
    _isGameEnded = true;
    _gameState = GameState.gameOver;
    _timer.stop();
    _safeNotifyListeners();
  }

  void moveLeft() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _isGameEnded) {
      return;
    }

    if (_engine.canMoveLeft(_currentTetromino!)) {
      _currentTetromino!.moveLeft();
      _safeNotifyListeners();
    }
  }

  void moveRight() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _isGameEnded) {
      return;
    }

    if (_engine.canMoveRight(_currentTetromino!)) {
      _currentTetromino!.moveRight();
      _safeNotifyListeners();
    }
  }

  void moveDown() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _isGameEnded) {
      return;
    }

    if (_engine.canMoveDown(_currentTetromino!)) {
      _currentTetromino!.moveDown();
      _scoreCalculator.addSoftDropScore();
      _safeNotifyListeners();
    }
  }

  void hardDrop() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _isGameEnded) {
      return;
    }

    int dropDistance = 0;
    while (_engine.canMoveDown(_currentTetromino!)) {
      _currentTetromino!.moveDown();
      dropDistance++;
    }

    _scoreCalculator.addHardDropScore(dropDistance);
    _lockCurrentTetromino();
    _safeNotifyListeners();
  }

  void rotate() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _isGameEnded) {
      return;
    }

    final temp = _currentTetromino!.copy();
    temp.rotateClockwise();

    if (_engine.isValidPosition(temp)) {
      _currentTetromino!.rotateClockwise();
      _safeNotifyListeners();
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
        _safeNotifyListeners();
        return;
      }
    }

    final tempUp = rotated.copy();
    tempUp.y -= 1;
    if (_engine.isValidPosition(tempUp)) {
      _currentTetromino!.rotateClockwise();
      _currentTetromino!.y -= 1;
      _safeNotifyListeners();
    }
  }

  void hold() {
    if (_gameState != GameState.playing ||
        _currentTetromino == null ||
        _holdUsed ||
        _isGameEnded) {
      return;
    }

    if (_holdTetromino == null) {
      _holdTetromino = Tetromino(type: _currentTetromino!.type);
      _currentTetromino = _generator.getNext();
      _nextTetromino = _generator.peekNext();
    } else {
      final temp = Tetromino(type: _holdTetromino!.type);
      _holdTetromino = Tetromino(type: _currentTetromino!.type);
      _currentTetromino = temp;
    }

    if (!_engine.isValidPosition(_currentTetromino!)) {
      _gameOver();
      return;
    }

    _holdUsed = true;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer.dispose();
    super.dispose();
  }
}
