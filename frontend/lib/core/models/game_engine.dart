import 'package:frontend/core/models/board.dart';
import 'package:frontend/core/models/tetromino.dart';

class GameEngine {
  final Board board;

  GameEngine({required this.board});

  // 블록이 유효한 위치에 있는지 확인
  bool isValidPosition(Tetromino tetromino) {
    for(final pos in tetromino.positions) {
      if(!board.isInside(pos.x, pos.y)) {
        return false;
      }

      if(!board.isEmpty(pos.x, pos.y)) {
        return false;
      }
    }

    return true;
  }
  
  // 블록을 왼쪽으로 이동 가능한지
  bool canMoveLeft(Tetromino tetromino) {
    final temp = tetromino.copy();
    temp.moveLeft();
    return isValidPosition(temp);
  }
  
  // 블록을 오른쪽으로 이동 가능한지
  bool canMoveRight(Tetromino tetromino) {
    final temp = tetromino.copy();
    temp.moveRight();
    return isValidPosition(temp);
  }
  
  // 블록을 아래로 이동 가능한지
  bool canMoveDown(Tetromino tetromino) {
    final temp = tetromino.copy();
    temp.moveDown();
    return isValidPosition(temp);
  }
  
  // 블록을 회전할 수 있는지
  bool canRotate(Tetromino tetromino) {
    final temp = tetromino.copy();
    temp.rotateClockwise();
    return isValidPosition(temp);
  }
  
  // 블록을 보드에 고정 (lock)
  void lockTetromino(Tetromino tetromino) {
    for(final pos in tetromino.positions) {
      board.setCell(pos.x, pos.y, tetromino.colorCode);
    }
  }
}