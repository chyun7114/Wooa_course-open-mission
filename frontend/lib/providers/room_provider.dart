import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/room_model.dart';
import '../core/network/websocket_service.dart';
import '../core/services/room_api_service.dart';
import '../core/services/auth_storage_service.dart';

class RoomProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final RoomApiService _apiService = RoomApiService();
  final AuthStorageService _authStorage = AuthStorageService();

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

  RoomProvider() {}

  Future<void> connectWebSocket() async {
    await _wsService.connect();

    _userId = await _authStorage.getUserId();
    _nickname = await _authStorage.getNickname();

    debugPrint('👤 RoomProvider - User loaded: $_nickname ($_userId)');

    _setupWebSocketListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchRooms();
    });
  }

  void _setupWebSocketListeners() {
    debugPrint('🎧 Setting up WebSocket listeners');

    _wsService.on('roomListUpdated', (data) {
      debugPrint('🔔 Room list updated event received: $data');
      if (data['rooms'] != null) {
        _rooms = (data['rooms'] as List)
            .map((json) => RoomModel.fromJson(json))
            .toList();
        _applySearchFilter();
        notifyListeners();
        debugPrint('✅ Room list updated: ${_rooms.length} rooms');
      }
    });

    _wsService.on('playerJoined', (data) {
      debugPrint('🔔 Player joined event: $data');
    });

    _wsService.on('playerLeft', (data) {
      debugPrint('🔔 Player left event: $data');
    });
  }

  Future<void> fetchRooms() async {
    if (!_wsService.isConnected) {
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
