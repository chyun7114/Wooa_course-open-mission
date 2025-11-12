import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_waiting_provider.dart';
import '../core/models/room_model.dart';
import '../core/models/game_member.dart';
import '../widgets/waiting_room/player_card.dart';
import '../widgets/waiting_room/chat_panel.dart';
import '../widgets/waiting_room/ready_button.dart';
import '../widgets/waiting_room/start_game_button.dart';

class RoomWaitingScreen extends StatefulWidget {
  final RoomModel room;
  final String userId;

  const RoomWaitingScreen({
    super.key,
    required this.room,
    required this.userId,
  });

  @override
  State<RoomWaitingScreen> createState() => _RoomWaitingScreenState();
}

class _RoomWaitingScreenState extends State<RoomWaitingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomWaitingProvider>().joinRoom(widget.room, widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final confirmed = await _showLeaveConfirmDialog();
        if (confirmed == true && mounted) {
          await context.read<RoomWaitingProvider>().leaveRoom();
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.room.name),
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showRoomInfo,
            ),
          ],
        ),
        body: Consumer<RoomWaitingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.members.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 왼쪽: 플레이어 목록
                      Expanded(flex: 2, child: _buildPlayerSection(provider)),

                      const SizedBox(width: 16),

                      // 오른쪽: 채팅 패널
                      Expanded(flex: 3, child: _buildChatSection(provider)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerSection(RoomWaitingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 섹션 타이틀
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                '플레이어 (${provider.members.length}/${widget.room.maxPlayers})',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 플레이어 카드들
        Expanded(
          child: ListView.builder(
            itemCount: provider.members.length,
            itemBuilder: (context, index) {
              final member = provider.members[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlayerCard(
                  member: member,
                  isCurrentUser: member.id == provider.currentUserId,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 하단 버튼
        if (provider.isHost)
          StartGameButton(
            canStart: provider.canStartGame,
            onPressed: _startGame,
            isLoading: provider.isLoading,
          )
        else if (provider.currentUserId != null && provider.members.isNotEmpty)
          ReadyButton(
            isReady: provider.members
                .firstWhere(
                  (m) => m.id == provider.currentUserId,
                  orElse: () => GameMember(
                    id: '',
                    username: '',
                    isHost: false,
                    isReady: false,
                  ),
                )
                .isReady,
            onPressed: () => context.read<RoomWaitingProvider>().toggleReady(),
            isLoading: provider.isLoading,
          ),
      ],
    );
  }

  Widget _buildChatSection(RoomWaitingProvider provider) {
    return ChatPanel(
      messages: provider.messages,
      onSendMessage: (message) =>
          context.read<RoomWaitingProvider>().sendMessage(message),
      currentUserId: provider.currentUserId ?? '',
    );
  }

  Future<void> _startGame() async {
    final provider = context.read<RoomWaitingProvider>();
    final success = await provider.startGame();

    if (mounted && success) {
      // TODO: 게임 화면으로 이동
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게임을 시작합니다!')));
    }
  }

  Future<bool?> _showLeaveConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('방 나가기', style: TextStyle(color: Colors.white)),
        content: const Text(
          '정말 방을 나가시겠습니까?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('방 정보', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('방 이름', widget.room.name),
            _buildInfoRow('방장', widget.room.hostName),
            _buildInfoRow(
              '인원',
              '${widget.room.currentPlayers}/${widget.room.maxPlayers}',
            ),
            _buildInfoRow('상태', widget.room.status),
            _buildInfoRow('생성 시간', _formatDateTime(widget.room.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
