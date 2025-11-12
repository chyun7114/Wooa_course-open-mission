import 'package:flutter/material.dart';
import '../../core/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onJoin;

  const RoomCard({super.key, required this.room, required this.onJoin});

  Color _getStatusColor() {
    switch (room.status) {
      case 'waiting':
        return Colors.green;
      case 'playing':
        return Colors.orange;
      case 'full':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (room.status) {
      case 'waiting':
        return '대기 중';
      case 'playing':
        return '게임 중';
      case 'full':
        return '인원 마감';
      default:
        return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getStatusColor().withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        onTap: room.canJoin ? onJoin : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 방 이름
              Text(
                room.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 호스트 정보
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      room.hostName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 하단 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 플레이어 수
                  _InfoBadge(
                    icon: Icons.people,
                    text: '${room.currentPlayers}/${room.maxPlayers}',
                    backgroundColor: Colors.grey[800]!,
                    textColor: Colors.grey[400]!,
                  ),

                  // 상태
                  _InfoBadge(
                    text: _getStatusText(),
                    backgroundColor: _getStatusColor().withOpacity(0.2),
                    textColor: _getStatusColor(),
                    borderColor: _getStatusColor(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _InfoBadge({
    this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: borderColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
