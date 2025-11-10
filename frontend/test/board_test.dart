import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/board.dart';

void main() {
  group('Board 모델 테스트', () {
    
    test('보드가 올바르게 초기화되는지 확인', () {
      // given
      final board = Board(width: 10, height: 20);
      
      // then
      expect(board.width, 10);
      expect(board.height, 20);
      
      for (int y = 0; y < board.height; y++) {
        for (int x = 0; x < board.width; x++) {
          expect(board.getCell(x, y), 0);
        }
      }
    });
    
    test('isInside 메서드가 올바르게 동작하는지 확인', () {
      // given
      final board = Board(width: 10, height: 20);
      
      // then
      expect(board.isInside(0, 0), true);
      expect(board.isInside(5, 10), true);
      expect(board.isInside(9, 19), true);
      
      // then
      expect(board.isInside(-1, 0), false);
      expect(board.isInside(0, -1), false);
      expect(board.isInside(10, 0), false);
      expect(board.isInside(0, 20), false);
    });
    
    test('setCell과 getCell이 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      board.setCell(5, 10, 3);
      expect(board.getCell(5, 10), 3);
      
      board.setCell(0, 0, 1);
      board.setCell(9, 19, 7);
      expect(board.getCell(0, 0), 1);
      expect(board.getCell(9, 19), 7);
      
      expect(board.getCell(-1, 0), -1);
      expect(board.getCell(10, 20), -1);
    });
    
    test('isEmpty 메서드가 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      expect(board.isEmpty(5, 10), true);
      
      board.setCell(5, 10, 2);
      expect(board.isEmpty(5, 10), false);
      
      board.setCell(5, 10, 0);
      expect(board.isEmpty(5, 10), true);
    });
    
    test('isLineFull 메서드가 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      expect(board.isLineFull(19), false);
      
      for (int x = 0; x < 10; x++) {
        board.setCell(x, 19, 1);
      }
      expect(board.isLineFull(19), true);
      
      board.setCell(5, 19, 0);
      expect(board.isLineFull(19), false);
    });
    
    test('clearFullLines 메서드가 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      for (int x = 0; x < 10; x++) {
        board.setCell(x, 19, 1);
      }
      
      board.setCell(0, 18, 2);
      board.setCell(1, 18, 2);
      
      int cleared = board.clearFullLines();
      expect(cleared, 1);
      
      expect(board.getCell(0, 19), 2);
      expect(board.getCell(1, 19), 2);
      expect(board.getCell(2, 19), 0);
    });
    
    test('여러 줄 동시 제거가 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      for (int x = 0; x < 10; x++) {
        board.setCell(x, 18, 1);
        board.setCell(x, 19, 1);
      }
      
      int cleared = board.clearFullLines();
      expect(cleared, 2);
      
      expect(board.isLineFull(18), false);
      expect(board.isLineFull(19), false);
    });
    
    test('reset 메서드가 올바르게 동작하는지 확인', () {
      final board = Board(width: 10, height: 20);
      
      board.setCell(5, 10, 3);
      board.setCell(3, 15, 5);
      
      board.reset();
      
      for (int y = 0; y < board.height; y++) {
        for (int x = 0; x < board.width; x++) {
          expect(board.getCell(x, y), 0);
        }
      }
    });
    
    test('copy 메서드가 깊은 복사를 수행하는지 확인', () {
      final board = Board(width: 10, height: 20);
      board.setCell(5, 10, 3);
      
      final copy = board.copy();
      
      expect(copy.getCell(5, 10), 3);
      
      copy.setCell(5, 10, 7);
      expect(board.getCell(5, 10), 3);
      expect(copy.getCell(5, 10), 7);
    });
  });
}
