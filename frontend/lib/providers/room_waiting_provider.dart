import 'package:flutter/material.dart';
import '../core/models/room_model.dart';
import '../core/models/game_member.dart';
import '../core/models/chat_message.dart';
import '../core/network/websocket_service.dart';

class RoomWaitingProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();

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

  // WebSocket 이벤트 리스너 설정
  void _setupWebSocketListeners() {
    debugPrint('🎧 [RoomWaiting] Setting up WebSocket listeners');

    _wsService.on('playerJoined', (data) {
      debugPrint('🔔 [RoomWaiting] Player joined: $data');
      _handlePlayerJoined(data);
    });

    _wsService.on('playerLeft', (data) {
      debugPrint('🔔 [RoomWaiting] Player left: $data');
      _handlePlayerLeft(data);
    });

    _wsService.on('readyStateChanged', (data) {
      debugPrint('🔔 [RoomWaiting] Ready state changed: $data');
      _handleReadyStateChanged(data);
    });

    _wsService.on('gameStarted', (data) {
      debugPrint('🔔 [RoomWaiting] Game started: $data');
      _handleGameStarted(data);
    });

    _wsService.on('chatMessage', (data) {
      debugPrint('🔔 [RoomWaiting] Chat message: $data');
      _handleChatMessage(data);
    });
  }

  void _handlePlayerJoined(dynamic data) {
    if (data['room'] != null) {
      _updateRoomData(data['room']);
    }

    if (data['player'] != null) {
      final playerData = data['player'];
      addSystemMessage('${playerData['nickname']}님이 입장했습니다.');
    }
  }

  void _handlePlayerLeft(dynamic data) {
    if (data['room'] != null) {
      _updateRoomData(data['room']);
    }

    if (data['nickname'] != null) {
      addSystemMessage('${data['nickname']}님이 퇴장했습니다.');
    }

    if (data['newHostId'] != null) {
      addSystemMessage('방장이 변경되었습니다.');
    }
  }

  void _handleReadyStateChanged(dynamic data) {
    if (data['room'] != null) {
      _updateRoomData(data['room']);
    }
  }

  // 게임 시작 처리
  void _handleGameStarted(dynamic data) {
    addSystemMessage('게임이 시작됩니다!');
    _isGameStarted = true;
    notifyListeners();
  }

  // 게임 시작 플래그
  bool _isGameStarted = false;
  bool get isGameStarted => _isGameStarted;

  void _handleChatMessage(dynamic data) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: data['playerId'] ?? '',
      senderName: data['nickname'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  void _updateRoomData(dynamic roomData) {
    _currentRoom = RoomModel.fromJson(roomData);

    if (roomData['players'] != null) {
      _members = (roomData['players'] as List)
          .map(
            (p) => GameMember(
              id: p['id'] ?? '',
              username: p['nickname'] ?? 'Unknown',
              isHost: p['isHost'] ?? false,
              isReady: p['isReady'] ?? false,
            ),
          )
          .toList();
    }

    notifyListeners();
  }

  Future<void> joinRoom(RoomModel room, String userId) async {
    _isLoading = true;
    notifyListeners();

    _currentRoom = room;
    _currentUserId = userId;

    _setupWebSocketListeners();

    _wsService.emitWithAck('getRoomDetail', {'roomId': room.id}, (response) {
      debugPrint('📥 [RoomWaiting] Room detail response: $response');

      if (response['success'] == true && response['room'] != null) {
        _updateRoomData(response['room']);
        addSystemMessage('${room.name} 방에 입장했습니다.');
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleReady() async {
    if (isHost) return;
    if (_currentRoom == null) return;

    _isLoading = true;
    notifyListeners();

    _wsService.emitWithAck('toggleReady', {'roomId': _currentRoom!.id}, (
      response,
    ) {
      debugPrint('📥 [RoomWaiting] Toggle ready response: $response');

      if (response['success'] != true) {
        addSystemMessage('준비 상태 변경에 실패했습니다.');
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> startGame() async {
    if (!canStartGame) return false;
    if (_currentRoom == null) return false;

    _isLoading = true;
    notifyListeners();

    bool success = false;

    _wsService.emitWithAck('startGame', {'roomId': _currentRoom!.id}, (
      response,
    ) {
      debugPrint('📥 [RoomWaiting] Start game response: $response');

      success = response['success'] == true;

      if (!success) {
        addSystemMessage(response['message'] ?? '게임 시작에 실패했습니다.');
      }

      _isLoading = false;
      notifyListeners();
    });

    return success;
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (_currentRoom == null) return;

    _wsService.emitWithAck(
      'sendChatMessage',
      {'roomId': _currentRoom!.id, 'message': message.trim()},
      (response) {
        debugPrint('📥 [RoomWaiting] Send message response: $response');

        if (response['success'] != true) {
          addSystemMessage('메시지 전송에 실패했습니다.');
        }
      },
    );
  }

  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    _isLoading = true;
    notifyListeners();

    _wsService.emitWithAck('leaveRoom', {'roomId': _currentRoom!.id}, (
      response,
    ) {
      debugPrint('📥 [RoomWaiting] Leave room response: $response');

      _wsService.off('playerJoined');
      _wsService.off('playerLeft');
      _wsService.off('readyStateChanged');
      _wsService.off('gameStarted');
      _wsService.off('chatMessage');

      _currentRoom = null;
      _members.clear();
      _messages.clear();
      _currentUserId = null;

      _isLoading = false;
      notifyListeners();
    });
  }

  void addSystemMessage(String message) {
    _messages.add(ChatMessage.system(message));
    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.off('playerJoined');
    _wsService.off('playerLeft');
    _wsService.off('readyStateChanged');
    _wsService.off('gameStarted');
    _wsService.off('chatMessage');

    _members.clear();
    _messages.clear();
    super.dispose();
  }
}
