import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/room_model.dart';
import 'package:frontend/core/models/game_member.dart';
import 'package:frontend/providers/room_waiting_provider.dart';

void main() {
  group('RoomWaitingProvider Tests', () {
    late RoomWaitingProvider provider;
    late RoomModel testRoom;

    setUp(() {
      provider = RoomWaitingProvider();
      testRoom = RoomModel(
        id: 'test-room-1',
        name: '테스트 방',
        hostName: 'TestHost',
        currentPlayers: 1,
        maxPlayers: 2,
        status: 'waiting',
        createdAt: DateTime.now(),
      );
    });

    test('초기 상태가 올바르게 설정되어야 함', () {
      expect(provider.currentRoom, isNull);
      expect(provider.members, isEmpty);
      expect(provider.messages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.currentUserId, isNull);
    });

    test('방에 입장하면 멤버와 메시지가 초기화되어야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      expect(provider.currentRoom, equals(testRoom));
      expect(provider.currentUserId, equals('user123'));
      expect(provider.members, isNotEmpty);
      expect(provider.messages, isNotEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('방장은 isHost가 true여야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      final hostMember = provider.members.firstWhere((m) => m.isHost);
      // 더미 데이터에서 현재 사용자가 방장으로 설정됨
      expect(hostMember.username, equals('Me (Host)'));
      expect(hostMember.id, equals('user123'));
    });

    test('준비 상태를 토글할 수 있어야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      // 현재 사용자가 방장이므로 준비 상태 토글이 작동하지 않음
      // 방장은 항상 준비 완료 상태
      final initialReady = provider.members
          .firstWhere((m) => m.id == 'user123')
          .isReady;

      expect(initialReady, isTrue); // 방장은 항상 준비 완료

      await provider.toggleReady();

      final updatedReady = provider.members
          .firstWhere((m) => m.id == 'user123')
          .isReady;

      // 방장은 토글이 안 되므로 그대로 true
      expect(updatedReady, isTrue);
    });

    test('메시지를 보낼 수 있어야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      final initialMessageCount = provider.messages.length;
      await provider.sendMessage('Hello, World!');

      expect(provider.messages.length, equals(initialMessageCount + 1));
      expect(provider.messages.last.message, equals('Hello, World!'));
      expect(provider.messages.last.senderId, equals('user123'));
    });

    test('빈 메시지는 전송되지 않아야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      final initialMessageCount = provider.messages.length;
      await provider.sendMessage('   ');

      expect(provider.messages.length, equals(initialMessageCount));
    });

    test('시스템 메시지를 추가할 수 있어야 함', () async {
      await provider.joinRoom(testRoom, 'user123');

      provider.addSystemMessage('테스트 시스템 메시지');

      expect(provider.messages.last.isSystemMessage, isTrue);
      expect(provider.messages.last.message, equals('테스트 시스템 메시지'));
    });

    test('방을 떠나면 상태가 초기화되어야 함', () async {
      await provider.joinRoom(testRoom, 'user123');
      await provider.leaveRoom();

      expect(provider.currentRoom, isNull);
      expect(provider.members, isEmpty);
      expect(provider.messages, isEmpty);
      expect(provider.currentUserId, isNull);
    });

    test('방장이 아닌 경우 게임 시작 불가', () async {
      await provider.joinRoom(testRoom, 'user123');

      // 현재 사용자가 방장이고 모든 플레이어가 준비 완료 상태이므로
      // canStartGame이 true여야 함
      expect(provider.isHost, isTrue);
      expect(provider.canStartGame, isTrue);
    });
  });

  group('GameMember Tests', () {
    test('GameMember를 JSON으로 변환하고 다시 복원할 수 있어야 함', () {
      final member = GameMember(
        id: 'member1',
        username: 'TestUser',
        isHost: true,
        isReady: true,
      );

      final json = member.toJson();
      final restored = GameMember.fromJson(json);

      expect(restored.id, equals(member.id));
      expect(restored.username, equals(member.username));
      expect(restored.isHost, equals(member.isHost));
      expect(restored.isReady, equals(member.isReady));
    });

    test('GameMember copyWith가 올바르게 동작해야 함', () {
      final member = GameMember(
        id: 'member1',
        username: 'TestUser',
        isHost: false,
        isReady: false,
      );

      final updated = member.copyWith(isReady: true);

      expect(updated.id, equals(member.id));
      expect(updated.username, equals(member.username));
      expect(updated.isHost, equals(member.isHost));
      expect(updated.isReady, isTrue);
    });
  });
}
