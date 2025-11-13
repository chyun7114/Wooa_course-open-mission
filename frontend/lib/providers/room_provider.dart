import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/room_model.dart';
import '../core/network/websocket_service.dart';
import '../core/services/room_api_service.dart';

class RoomProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final RoomApiService _apiService = RoomApiService();

  List<RoomModel> _rooms = [];
  List<RoomModel> _filteredRooms = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _userId;
  String? _nickname;

  List<RoomModel> get rooms =>
      _filteredRooms.isEmpty && _searchQuery.isEmpty ? _rooms : _filteredRooms;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isConnected => _wsService.isConnected;
  String? get userId => _userId;
  String? get nickname => _nickname;

  RoomProvider() {
    _setupWebSocketListeners();
  }

  // WebSocket 연결 (토큰은 자동으로 AuthStorageService에서 가져옴)
  Future<void> connectWebSocket() async {
    await _wsService.connect();

    // 연결 후 방 목록 가져오기
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchRooms();
    });
  }

  // WebSocket 이벤트 리스너 설정
  void _setupWebSocketListeners() {
    // 방 목록 업데이트
    _wsService.on('roomListUpdated', (data) {
      debugPrint('Room list updated: $data');
      if (data['rooms'] != null) {
        _rooms = (data['rooms'] as List)
            .map((json) => RoomModel.fromJson(json))
            .toList();
        _applySearchFilter();
        notifyListeners();
      }
    });

    // 플레이어 입장
    _wsService.on('playerJoined', (data) {
      debugPrint('Player joined: $data');
      // 필요한 경우 UI 업데이트
    });

    // 플레이어 퇴장
    _wsService.on('playerLeft', (data) {
      debugPrint('Player left: $data');
      // 필요한 경우 UI 업데이트
    });
  }

  Future<void> fetchRooms() async {
    if (!_wsService.isConnected) {
      // WebSocket이 연결되지 않은 경우 REST API 사용
      await _fetchRoomsFromApi();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _wsService.emitWithAck('getRoomList', {}, (response) {
        if (response['success'] == true && response['rooms'] != null) {
          _rooms = (response['rooms'] as List)
              .map((json) => RoomModel.fromJson(json))
              .toList();
          _applySearchFilter();
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchRoomsFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await _apiService.getRoomList();
      _applySearchFilter();
    } catch (e) {
      debugPrint('Error fetching rooms from API: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchRooms(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) {
        return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            room.hostName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<Map<String, dynamic>> createRoom({
    required String title,
    required int maxPlayers,
    String? password,
  }) async {
    if (!_wsService.isConnected) {
      return {'success': false, 'message': 'WebSocket이 연결되지 않았습니다.'};
    }

    _isLoading = true;
    notifyListeners();

    final completer = Completer<Map<String, dynamic>>();

    _wsService.emitWithAck(
      'createRoom',
      {
        'title': title,
        'maxPlayers': maxPlayers,
        if (password != null && password.isNotEmpty) 'password': password,
      },
      (response) {
        _isLoading = false;
        notifyListeners();
        completer.complete(response as Map<String, dynamic>);
      },
    );

    return completer.future;
  }

  Future<Map<String, dynamic>> joinRoom(
    String roomId, {
    String? password,
  }) async {
    if (!_wsService.isConnected) {
      return {'success': false, 'message': 'WebSocket이 연결되지 않았습니다.'};
    }

    _isLoading = true;
    notifyListeners();

    final completer = Completer<Map<String, dynamic>>();

    _wsService.emitWithAck(
      'joinRoom',
      {
        'roomId': roomId,
        if (password != null && password.isNotEmpty) 'password': password,
      },
      (response) {
        _isLoading = false;
        notifyListeners();
        completer.complete(response as Map<String, dynamic>);
      },
    );

    return completer.future;
  }

  void clearSearch() {
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  void refresh() {
    fetchRooms();
  }

  @override
  void dispose() {
    _wsService.off('roomListUpdated');
    _wsService.off('playerJoined');
    _wsService.off('playerLeft');
    super.dispose();
  }
}
