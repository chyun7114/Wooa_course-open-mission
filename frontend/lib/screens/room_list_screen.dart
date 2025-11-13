import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../core/models/room_model.dart';
import '../widgets/room/room_card.dart';
import '../widgets/room/room_search_bar.dart';
import '../widgets/room/empty_room_view.dart';
import '../widgets/room/create_room_dialog.dart';
import 'room_waiting_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomProvider = context.read<RoomProvider>();

      // WebSocket 연결 (토큰은 AuthStorageService에서 자동으로 가져옴)
      roomProvider.connectWebSocket();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateRoomDialog(
        onCreate: (title, maxPlayers, password) async {
          final result = await context.read<RoomProvider>().createRoom(
            title: title,
            maxPlayers: maxPlayers,
            password: password,
          );

          if (mounted) {
            if (result['success'] == true) {
              _showSnackBar('방이 생성되었습니다');
              // 생성된 방으로 자동 입장
              if (result['room'] != null) {
                final roomData = result['room'];
                final roomProvider = context.read<RoomProvider>();

                final room = RoomModel.fromJson(roomData);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomWaitingScreen(
                      room: room,
                      userId: roomProvider.userId ?? 'guest',
                    ),
                  ),
                );
              }
            } else {
              _showSnackBar(result['message'] ?? '방 생성에 실패했습니다', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멀티플레이 방 목록'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RoomProvider>().refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // 검색 바
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RoomSearchBar(
                  controller: _searchController,
                  showClearButton: _searchController.text.isNotEmpty,
                  onChanged: (value) {
                    setState(() {});
                    context.read<RoomProvider>().searchRooms(value);
                  },
                  onClear: () {
                    setState(() {
                      _searchController.clear();
                    });
                    context.read<RoomProvider>().clearSearch();
                  },
                ),
              ),

              // 방 리스트
              Expanded(
                child: Consumer<RoomProvider>(
                  builder: (context, roomProvider, child) {
                    if (roomProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (roomProvider.rooms.isEmpty) {
                      return EmptyRoomView(
                        isSearchResult: roomProvider.searchQuery.isNotEmpty,
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: roomProvider.rooms.length > 6
                          ? 6
                          : roomProvider.rooms.length,
                      itemBuilder: (context, index) {
                        final room = roomProvider.rooms[index];
                        return RoomCard(
                          room: room,
                          onJoin: () => _joinRoom(room),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoomDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('방 만들기'),
      ),
    );
  }

  void _joinRoom(RoomModel room) async {
    if (!room.canJoin) {
      _showSnackBar(room.isFull ? '방이 가득 찼습니다' : '게임이 진행 중입니다', isError: true);
      return;
    }

    // 비밀번호가 필요한 경우 입력 받기
    String? password;
    if (room.isPrivate) {
      password = await _showPasswordDialog();
      if (password == null) return; // 취소한 경우
    }

    final result = await context.read<RoomProvider>().joinRoom(
      room.id,
      password: password,
    );

    if (mounted) {
      if (result['success'] == true) {
        // 방 대기실 화면으로 이동
        final roomProvider = context.read<RoomProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomWaitingScreen(
              room: room,
              userId: roomProvider.userId ?? 'guest',
            ),
          ),
        );
      } else {
        _showSnackBar(result['message'] ?? '방 참여에 실패했습니다', isError: true);
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('비밀번호 입력', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '비밀번호',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
