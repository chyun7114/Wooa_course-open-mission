import 'dart:math';
import '../models/tetromino.dart';

class TetrominoGenerator {
  final Random _random = Random();
  Tetromino? _nextTetromino;
  
  Tetromino generate() {
    final types = TetrominoType.values;
    final randomType = types[_random.nextInt(types.length)];
    return Tetromino(type: randomType);
  }
  
  Tetromino getNext() {
    final current = _nextTetromino ?? generate();
    _nextTetromino = generate();
    return current;
  }
  
  Tetromino? peekNext() {
    return _nextTetromino;
  }
  
  void initialize() {
    _nextTetromino = generate();
  }
  
  void reset() {
    _nextTetromino = null;
  }
}
