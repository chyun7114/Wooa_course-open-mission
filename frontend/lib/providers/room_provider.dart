import 'package:flutter/material.dart';
import '../core/models/room_model.dart';

class RoomProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];
  List<RoomModel> _filteredRooms = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<RoomModel> get rooms =>
      _filteredRooms.isEmpty && _searchQuery.isEmpty ? _rooms : _filteredRooms;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  RoomProvider() {
    // 초기 더미 데이터 생성
    _generateDummyRooms();
  }

  void _generateDummyRooms() {
    _rooms = [
      RoomModel(
        id: '1',
        name: '초보자의 방',
        hostName: 'Player1',
        currentPlayers: 1,
        maxPlayers: 2,
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RoomModel(
        id: '2',
        name: '고수들만 오세요',
        hostName: 'ProGamer',
        currentPlayers: 2,
        maxPlayers: 2,
        status: 'playing',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      RoomModel(
        id: '3',
        name: '친선 경기',
        hostName: 'FriendlyUser',
        currentPlayers: 1,
        maxPlayers: 2,
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      RoomModel(
        id: '4',
        name: '빠른 게임',
        hostName: 'SpeedRunner',
        currentPlayers: 2,
        maxPlayers: 2,
        status: 'full',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      RoomModel(
        id: '5',
        name: '연습용 방',
        hostName: 'Trainer',
        currentPlayers: 1,
        maxPlayers: 2,
        status: 'waiting',
        createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ];
    _filteredRooms = List.from(_rooms);
    notifyListeners();
  }

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 방 목록 가져오기
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  void searchRooms(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) {
        return room.name.toLowerCase().contains(query.toLowerCase()) ||
            room.hostName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> createRoom(String roomName) async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 방 생성하기
    await Future.delayed(const Duration(seconds: 1));

    final newRoom = RoomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: roomName,
      hostName: 'CurrentUser', // TODO: 실제 사용자 이름으로 변경
      currentPlayers: 1,
      maxPlayers: 2,
      status: 'waiting',
      createdAt: DateTime.now(),
    );

    _rooms.insert(0, newRoom);
    _filteredRooms = List.from(_rooms);

    _isLoading = false;
    notifyListeners();

    return true;
  }

  Future<bool> joinRoom(String roomId) async {
    _isLoading = true;
    notifyListeners();

    // TODO: API 호출로 방 참여하기
    await Future.delayed(const Duration(seconds: 1));

    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = _rooms[roomIndex];
      if (room.canJoin) {
        // 방 참여 성공 로직
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredRooms = List.from(_rooms);
    notifyListeners();
  }

  void refresh() {
    fetchRooms();
  }
}
