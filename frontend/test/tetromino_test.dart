/// Tetromino 모델의 단위 테스트
/// 블록의 회전, 이동, 형태 등이 올바르게 동작하는지 검증합니다.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/tetromino.dart';

void main() {
  group('Tetromino 모델 테스트', () {
    
    test('테트로미노가 올바르게 생성되는지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.I);
      
      expect(tetromino.type, TetrominoType.I);
      expect(tetromino.rotation, 0);
      expect(tetromino.x, 3);
      expect(tetromino.y, 0);
    });
    
    test('각 블록 타입의 색상 코드가 올바른지 확인', () {
      expect(Tetromino(type: TetrominoType.I).colorCode, 1);
      expect(Tetromino(type: TetrominoType.O).colorCode, 2);
      expect(Tetromino(type: TetrominoType.T).colorCode, 3);
      expect(Tetromino(type: TetrominoType.S).colorCode, 4);
      expect(Tetromino(type: TetrominoType.Z).colorCode, 5);
      expect(Tetromino(type: TetrominoType.J).colorCode, 6);
      expect(Tetromino(type: TetrominoType.L).colorCode, 7);
    });
    
    test('I 블록의 형태가 올바른지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.I);
      final shape = tetromino.shape;
      
      // 0도 회전 상태: 가로 막대
      expect(shape[1], [1, 1, 1, 1]);
      expect(shape.length, 4);
    });
    
    test('O 블록의 형태가 올바른지 확인 (회전해도 동일)', () {
      final tetromino = Tetromino(type: TetrominoType.O);
      
      final shape0 = tetromino.shape;
      tetromino.rotateClockwise();
      final shape1 = tetromino.shape;
      
      // O 블록은 회전해도 모양이 같음
      expect(shape0, shape1);
    });
    
    test('시계방향 회전이 올바르게 동작하는지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.T);
      
      expect(tetromino.rotation, 0);
      
      tetromino.rotateClockwise();
      expect(tetromino.rotation, 1);
      
      tetromino.rotateClockwise();
      expect(tetromino.rotation, 2);
      
      tetromino.rotateClockwise();
      expect(tetromino.rotation, 3);
      
      // 4번 회전하면 다시 0으로
      tetromino.rotateClockwise();
      expect(tetromino.rotation, 0);
    });
    
    test('반시계방향 회전이 올바르게 동작하는지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.T);
      
      tetromino.rotateCounterClockwise();
      expect(tetromino.rotation, 3);
      
      tetromino.rotateCounterClockwise();
      expect(tetromino.rotation, 2);
      
      tetromino.rotateCounterClockwise();
      expect(tetromino.rotation, 1);
      
      tetromino.rotateCounterClockwise();
      expect(tetromino.rotation, 0);
    });
    
    test('블록 이동이 올바르게 동작하는지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.T, x: 5, y: 10);
      
      // 왼쪽 이동
      tetromino.moveLeft();
      expect(tetromino.x, 4);
      
      // 오른쪽 이동
      tetromino.moveRight();
      tetromino.moveRight();
      expect(tetromino.x, 6);
      
      // 아래로 이동
      tetromino.moveDown();
      expect(tetromino.y, 11);
      
      // 위로 이동
      tetromino.moveUp();
      expect(tetromino.y, 10);
    });
    
    test('블록 복사가 올바르게 동작하는지 확인', () {
      final original = Tetromino(type: TetrominoType.J, rotation: 2, x: 5, y: 10);
      final copy = original.copy();
      
      expect(copy.type, original.type);
      expect(copy.rotation, original.rotation);
      expect(copy.x, original.x);
      expect(copy.y, original.y);
      
      // 복사본 수정 시 원본에 영향 없어야 함
      copy.moveRight();
      copy.rotateClockwise();
      
      expect(original.x, 5);
      expect(original.rotation, 2);
      expect(copy.x, 6);
      expect(copy.rotation, 3);
    });
    
    test('블록의 실제 위치(positions)가 올바른지 확인 - I 블록', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 3, y: 0);
      final positions = tetromino.positions;
      
      // I 블록 0도 회전: 가로 막대, y=1 줄에 4개
      expect(positions.length, 4);
      expect(positions.contains(Position(3, 1)), true);
      expect(positions.contains(Position(4, 1)), true);
      expect(positions.contains(Position(5, 1)), true);
      expect(positions.contains(Position(6, 1)), true);
    });
    
    test('블록의 실제 위치(positions)가 올바른지 확인 - O 블록', () {
      final tetromino = Tetromino(type: TetrominoType.O, x: 4, y: 5);
      final positions = tetromino.positions;
      
      // O 블록: 2x2 정사각형
      expect(positions.length, 4);
      expect(positions.contains(Position(5, 6)), true);
      expect(positions.contains(Position(6, 6)), true);
      expect(positions.contains(Position(5, 7)), true);
      expect(positions.contains(Position(6, 7)), true);
    });
    
    test('블록의 실제 위치(positions)가 올바른지 확인 - T 블록', () {
      final tetromino = Tetromino(type: TetrominoType.T, x: 3, y: 0);
      final positions = tetromino.positions;
      
      // T 블록 0도 회전: ㅗ 모양
      expect(positions.length, 4);
      expect(positions.contains(Position(4, 1)), true); // 위 중앙
      expect(positions.contains(Position(3, 2)), true); // 아래 왼쪽
      expect(positions.contains(Position(4, 2)), true); // 아래 중앙
      expect(positions.contains(Position(5, 2)), true); // 아래 오른쪽
    });
    
    test('회전 후 블록의 위치가 올바르게 변경되는지 확인', () {
      final tetromino = Tetromino(type: TetrominoType.I, x: 3, y: 0);
      
      // 0도 회전: 가로
      var positions = tetromino.positions;
      expect(positions.length, 4);
      expect(positions.every((p) => p.y == 1), true); // 모두 같은 y 좌표
      
      // 90도 회전: 세로
      tetromino.rotateClockwise();
      positions = tetromino.positions;
      expect(positions.length, 4);
      expect(positions.every((p) => p.x == 5), true); // 모두 같은 x 좌표
    });
    
    test('모든 블록 타입이 4개의 셀을 차지하는지 확인', () {
      for (var type in TetrominoType.values) {
        final tetromino = Tetromino(type: type);
        final positions = tetromino.positions;
        
        // 테트로미노는 항상 4개의 블록으로 구성
        expect(positions.length, 4, reason: '$type 블록은 4개의 셀을 차지해야 합니다');
      }
    });
    
    test('Position 클래스의 동등성 비교가 올바른지 확인', () {
      final pos1 = Position(3, 5);
      final pos2 = Position(3, 5);
      final pos3 = Position(4, 5);
      
      expect(pos1 == pos2, true);
      expect(pos1 == pos3, false);
      expect(pos1.hashCode, pos2.hashCode);
    });
  });
}
