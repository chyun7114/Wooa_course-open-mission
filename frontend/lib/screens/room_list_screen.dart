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
      context.read<RoomProvider>().fetchRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateRoomDialog() {
    final TextEditingController roomNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => CreateRoomDialog(
        controller: roomNameController,
        onCancel: () => Navigator.pop(context),
        onCreate: () async {
          if (roomNameController.text.trim().isNotEmpty) {
            final success = await context.read<RoomProvider>().createRoom(
              roomNameController.text.trim(),
            );

            if (mounted) {
              Navigator.pop(context);
              if (success) {
                _showSnackBar('방이 생성되었습니다');
              }
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

    final success = await context.read<RoomProvider>().joinRoom(room.id);

    if (mounted) {
      if (success) {
        // 방 대기실 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomWaitingScreen(
              room: room,
              userId: 'current_user_id', // TODO: 실제 사용자 ID로 변경
            ),
          ),
        );
      } else {
        _showSnackBar('방 참여에 실패했습니다', isError: true);
      }
    }
  }
}
