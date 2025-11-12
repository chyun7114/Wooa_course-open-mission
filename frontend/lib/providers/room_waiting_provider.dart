import 'package:flutter/material.dart';
import '../core/models/room_model.dart';
import '../core/models/game_member.dart';
import '../core/models/chat_message.dart';

class RoomWaitingProvider extends ChangeNotifier {
  RoomModel? _currentRoom;
  List<GameMember> _members = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentUserId;

  RoomModel? get currentRoom => _currentRoom;
  List<GameMember> get members => _members;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  bool get isHost =>
      _members.any((member) => member.id == _currentUserId && member.isHost);

  bool get canStartGame {
    if (!isHost) return false;
    if (_members.length < 2) return false;
    return _members.where((m) => !m.isHost).every((m) => m.isReady);
  }

  Future<void> joinRoom(RoomModel room, String userId) async {
    _isLoading = true;
    notifyListeners();

    _currentRoom = room;
    _currentUserId = userId;

    // TODO: API 호출로 방 정보 가져오기
    await Future.delayed(const Duration(seconds: 1));

    // 더미 데이터 생성
    // 방장이 userId와 같으면 방을 생성한 경우
    final isCreator = userId == '1'; // TODO: 실제 방장 ID와 비교

    _members = [
      GameMember(id: '1', username: room.hostName, isHost: true, isReady: true),
      // 방장이 아니면 현재 사용자 추가
      if (!isCreator)
        GameMember(
          id: userId,
          username: 'CurrentUser',
          isHost: false,
          isReady: false,
        ),
    ];

    _messages = [
      ChatMessage.system('${room.hostName}님이 방을 생성했습니다.'),
      if (room.currentPlayers > 1) ChatMessage.system('CurrentUser님이 입장했습니다.'),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReady() async {
    if (isHost) return;

    final memberIndex = _members.indexWhere((m) => m.id == _currentUserId);
    if (memberIndex == -1) return;

    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 준비 상태 변경
    await Future.delayed(const Duration(milliseconds: 500));

    final member = _members[memberIndex];
    _members[memberIndex] = member.copyWith(isReady: !member.isReady);

    _messages.add(
      ChatMessage.system(
        '${member.username}님이 ${!member.isReady ? "준비" : "준비 취소"}했습니다.',
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> startGame() async {
    if (!canStartGame) return false;

    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 게임 시작
    await Future.delayed(const Duration(seconds: 1));

    _messages.add(ChatMessage.system('게임이 시작됩니다!'));

    _isLoading = false;
    notifyListeners();

    return true;
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final member = _members.firstWhere(
      (m) => m.id == _currentUserId,
      orElse: () =>
          GameMember(id: _currentUserId!, username: 'Unknown', isHost: false),
    );

    final chatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId!,
      senderName: member.username,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(chatMessage);
    notifyListeners();

    // TODO: API 호출로 메시지 전송
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> leaveRoom() async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 방 나가기
    await Future.delayed(const Duration(milliseconds: 500));

    _currentRoom = null;
    _members.clear();
    _messages.clear();
    _currentUserId = null;

    _isLoading = false;
    notifyListeners();
  }

  void addSystemMessage(String message) {
    _messages.add(ChatMessage.system(message));
    notifyListeners();
  }

  @override
  void dispose() {
    _members.clear();
    _messages.clear();
    super.dispose();
  }
}
