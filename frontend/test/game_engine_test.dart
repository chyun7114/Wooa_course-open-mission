import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/board.dart';
import 'package:frontend/core/models/game_engine.dart';
import 'package:frontend/core/models/tetromino.dart';

void main() {
  group("Game_Engine Test", () {
    late Board board;
    late GameEngine gameEngine;

    setUp(() {
      board = Board();
      gameEngine = GameEngine(board: board);
    });

    test("새 블록은 유효한 위치에 있어야 한다.", () {
      final tetromino = Tetromino(type: TetrominoType.I);
      expect(gameEngine.isValidPosition(tetromino),true);
    });

    test("보드 밖으로 나가는 블록은 유효하지 않다", () {
      final tetromino = Tetromino(type: TetrominoType.I, x: -1, y: -1);
      expect(gameEngine.isValidPosition(tetromino), false);
    });
    
    test("다른 블록과 겹치는 블록은 유효하지 않음", () {
      final tetromino1 = Tetromino(type: TetrominoType.O, x: 4, y: 18);
      gameEngine.lockTetromino(tetromino1);

      final tetromino2 = Tetromino(type: TetrominoType.O, x:4, y: 19);
      expect(gameEngine.isValidPosition(tetromino2), false);
    });
    
    test('왼쪽 벽에 닿으면 왼쪽 이동 불가', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 0, y: 0);
      expect(gameEngine.canMoveLeft(tetromino), false);
    });

    test('오른쪽 벽에 닿으면 오른쪽 이동 불가', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 6, y: 0, rotation: 0);
      expect(gameEngine.canMoveRight(tetromino), false);
    });

    test('바닥에 닿으면 아래 이동 불가', () {
      final tetromino = Tetromino(type: TetrominoType.O, x: 4, y: 18);
      expect(gameEngine.canMoveDown(tetromino), false);
    });

    test('중간 위치에서는 모든 방향 이동 가능', () {
      final tetromino = Tetromino(type: TetrominoType.T, x: 4, y: 10);
      expect(gameEngine.canMoveLeft(tetromino), true);
      expect(gameEngine.canMoveRight(tetromino), true);
      expect(gameEngine.canMoveDown(tetromino), true);
    });

    test('빈 공간에서는 회전 가능', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 4, y: 10);
      expect(gameEngine.canRotate(tetromino), true);
    });

    test('벽 근처에서 회전 불가능한 경우', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 8, y: 0, rotation: 0);
      expect(gameEngine.canRotate(tetromino), false);
    });

    test('블록을 보드에 고정하면 해당 위치가 채워짐', () {
      final tetromino = Tetromino(type: TetrominoType.O, x: 4, y: 0);
      gameEngine.lockTetromino(tetromino);

      final positions = tetromino.positions;
      for (final pos in positions) {
        expect(board.getCell(pos.x, pos.y), tetromino.colorCode);
      }
    });

    test('블록 고정 후 같은 위치에 새 블록 배치 불가', () {
      final tetromino1 = Tetromino(type: TetrominoType.T, x: 4, y: 0);
      gameEngine.lockTetromino(tetromino1);

      final tetromino2 = Tetromino(type: TetrominoType.T, x: 4, y: 0);
      expect(gameEngine.isValidPosition(tetromino2), false);
    });

    test('다른 블록 위에 블록을 쌓을 수 있음', () {
      // 바닥에 블록 고정
      final tetromino1 = Tetromino(type: TetrominoType.O, x: 4, y: 18);
      gameEngine.lockTetromino(tetromino1);

      // 그 위에 블록 배치
      final tetromino2 = Tetromino(type: TetrominoType.O, x: 4, y: 16);
      expect(gameEngine.isValidPosition(tetromino2), true);
    });

    test('블록이 다른 블록과 겹치면 아래 이동 불가', () {
      // 바닥에 블록 고정
      final tetromino1 = Tetromino(type: TetrominoType.O, x: 4, y: 18);
      gameEngine.lockTetromino(tetromino1);

      // 바로 위에 블록 배치
      final tetromino2 = Tetromino(type: TetrominoType.O, x: 4, y: 16);
      expect(gameEngine.canMoveDown(tetromino2), false);
    });

  });
}