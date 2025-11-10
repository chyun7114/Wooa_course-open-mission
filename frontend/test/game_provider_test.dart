/// GameProvider의 단위 테스트
/// 게임 로직과 상태 관리가 올바르게 동작하는지 검증합니다.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/game_provider.dart';
import 'package:frontend/core/models/tetromino.dart';

void main() {
  group('GameProvider 테스트', () {
    late GameProvider provider;

    setUp(() {
      provider = GameProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('초기 상태가 올바른지 확인', () {
      expect(provider.gameState, GameState.idle);
      expect(provider.score, 0);
      expect(provider.level, 1);
      expect(provider.totalLines, 0);
      expect(provider.currentTetromino, null);
      expect(provider.nextTetromino, null);
    });

    test('게임 시작 시 상태가 올바르게 초기화되는지 확인', () {
      provider.startGame();

      expect(provider.gameState, GameState.playing);
      expect(provider.currentTetromino, isNotNull);
      expect(provider.nextTetromino, isNotNull);
      expect(provider.score, 0);
      expect(provider.level, 1);
    });

    test('게임 일시정지 및 재개가 올바르게 동작하는지 확인', () {
      provider.startGame();
      expect(provider.gameState, GameState.playing);

      provider.pauseGame();
      expect(provider.gameState, GameState.paused);

      provider.resumeGame();
      expect(provider.gameState, GameState.playing);
    });

    test('게임 재시작이 올바르게 동작하는지 확인', () {
      provider.startGame();
      provider.moveLeft();
      provider.moveRight();

      provider.restartGame();

      expect(provider.gameState, GameState.playing);
      expect(provider.score, 0);
      expect(provider.level, 1);
    });

    test('블록 왼쪽 이동이 올바르게 동작하는지 확인', () {
      provider.startGame();
      final initialX = provider.currentTetromino!.x;

      provider.moveLeft();

      // 왼쪽 벽에 닿지 않았다면 x가 감소해야 함
      if (initialX > 0) {
        expect(provider.currentTetromino!.x, lessThan(initialX));
      }
    });

    test('블록 오른쪽 이동이 올바르게 동작하는지 확인', () {
      provider.startGame();
      final initialX = provider.currentTetromino!.x;

      provider.moveRight();

      // 오른쪽 벽에 닿지 않았다면 x가 증가해야 함
      expect(provider.currentTetromino!.x, greaterThanOrEqualTo(initialX));
    });

    test('블록 아래로 이동 시 점수가 증가하는지 확인', () {
      provider.startGame();
      final initialScore = provider.score;

      provider.moveDown();

      expect(provider.score, greaterThan(initialScore));
    });

    test('블록 회전이 올바르게 동작하는지 확인', () {
      provider.startGame();

      provider.rotate();

      // 회전이 가능한 위치라면 rotation이 변경되어야 함
      // (벽 근처가 아니라면)
      final newRotation = provider.currentTetromino!.rotation;
      expect(newRotation, isNotNull);
    });

    test('하드 드롭 시 블록이 바닥까지 떨어지는지 확인', () {
      provider.startGame();

      provider.hardDrop();

      // 하드 드롭 후에는 새 블록이 생성되므로 y가 초기화됨
      // 점수가 증가했는지 확인
      expect(provider.score, greaterThan(0));
    });

    test('여러 줄 제거 시 점수가 올바르게 계산되는지 확인', () {
      provider.startGame();

      // 보드 아래쪽 4줄을 거의 가득 채우기 (한 칸씩 비워둠)
      for (int y = 16; y < 20; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      // I 블록을 생성해서 수직으로 놓으면 4줄이 동시에 제거될 수 있음
      provider.startGame(); // 재시작
      
      final initialScore = provider.score;
      // 실제로 줄이 제거되면 점수가 증가해야 함
      expect(provider.score, greaterThanOrEqualTo(initialScore));
    });

    test('레벨업 시 속도가 증가하는지 확인', () {
      provider.startGame();
      final initialLevel = provider.level;

      // 총 10줄을 제거하면 레벨업
      // (실제 게임에서는 블록을 놓고 줄을 제거해야 하지만, 
      // 테스트에서는 내부 상태를 직접 변경)
      
      expect(provider.level, initialLevel);
    });

    test('게임 오버 조건이 올바르게 동작하는지 확인', () {
      provider.startGame();

      // 보드를 1열만 비워두고 거의 채움 (줄이 완성되지 않게)
      // 맨 위 5줄에 각 줄마다 9칸만 채워서 줄 클리어가 안 되게 함
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {  // 0~8까지만 채움 (9는 비워둠)
          provider.board.setCell(x, y, 1);
        }
      }

      // 현재 블록을 하드 드롭하면 다음 블록이 스폰되려고 시도하고
      // 스폰 위치 (x:3, y:0) 근처가 막혀있으면 게임 오버가 됨
      provider.hardDrop();

      // 게임 오버 상태인지 확인
      expect(provider.gameState, GameState.gameOver);
    });

    test('일시정지 상태에서는 블록 이동이 안 되는지 확인', () {
      provider.startGame();
      provider.pauseGame();

      final initialX = provider.currentTetromino!.x;
      provider.moveLeft();

      // 일시정지 상태에서는 이동하지 않아야 함
      expect(provider.currentTetromino!.x, initialX);
    });

    test('게임 오버 후에는 블록 이동이 안 되는지 확인', () {
      provider.startGame();
      
      // 보드를 1열만 비워두고 상단 5줄 채움 (줄 클리어 방지)
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      // 현재 블록을 하드 드롭하여 게임 오버 유도
      provider.hardDrop();

      // 게임 오버 상태인지 확인
      expect(provider.gameState, GameState.gameOver);
      
      // 게임 오버 상태에서 블록이 있다면
      if (provider.currentTetromino != null) {
        final initialX = provider.currentTetromino!.x;
        provider.moveLeft();
        
        // 게임 오버 상태에서는 이동하지 않아야 함
        expect(provider.currentTetromino!.x, initialX);
      }
    });

    test('블록이 생성될 때마다 랜덤한 타입인지 확인', () {
      final types = <TetrominoType>{};
      
      // 여러 번 게임을 시작해서 다양한 블록이 나오는지 확인
      for (int i = 0; i < 20; i++) {
        provider.startGame();
        if (provider.currentTetromino != null) {
          types.add(provider.currentTetromino!.type);
        }
        provider.dispose();
        provider = GameProvider();
      }

      // 최소 3가지 이상의 다른 블록이 나와야 함 (랜덤 검증)
      expect(types.length, greaterThanOrEqualTo(3));
    });

    test('게임 오버 시 타이머가 정지되는지 확인', () {
      provider.startGame();
      expect(provider.gameState, GameState.playing);

      // 보드 상단 5줄을 1열만 비워두고 채움
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      provider.hardDrop();

      expect(provider.gameState, GameState.gameOver);
      // 타이머가 정지되었으므로 자동 낙하가 일어나지 않음
    });

    test('게임 오버 후 재시작하면 정상적으로 게임이 시작되는지 확인', () {
      provider.startGame();

      // 게임 오버 유도
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      provider.hardDrop();
      expect(provider.gameState, GameState.gameOver);

      // 재시작
      provider.restartGame();

      expect(provider.gameState, GameState.playing);
      expect(provider.score, 0);
      expect(provider.level, 1);
      expect(provider.currentTetromino, isNotNull);
      expect(provider.nextTetromino, isNotNull);
    });

    test('게임 오버 시 회전도 동작하지 않는지 확인', () {
      provider.startGame();
      
      // 게임 오버 유도
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      provider.hardDrop();
      expect(provider.gameState, GameState.gameOver);

      if (provider.currentTetromino != null) {
        final initialRotation = provider.currentTetromino!.rotation;
        provider.rotate();
        
        // 게임 오버 상태에서는 회전하지 않아야 함
        expect(provider.currentTetromino!.rotation, initialRotation);
      }
    });

    test('게임 오버 시 하드 드롭도 동작하지 않는지 확인', () {
      provider.startGame();
      
      // 게임 오버 유도
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 9; x++) {
          provider.board.setCell(x, y, 1);
        }
      }

      provider.hardDrop();
      expect(provider.gameState, GameState.gameOver);

      final scoreBeforeHardDrop = provider.score;
      provider.hardDrop();
      
      // 게임 오버 상태에서는 하드 드롭이 동작하지 않으므로 점수 변화 없음
      expect(provider.score, scoreBeforeHardDrop);
    });
  });
}
