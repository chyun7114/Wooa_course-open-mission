import 'package:flutter/material.dart';
import '../../core/models/game_member.dart';

class PlayerCard extends StatelessWidget {
  final GameMember member;
  final bool isCurrentUser;

  const PlayerCard({
    super.key,
    required this.member,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? Colors.blue
              : member.isReady
              ? Colors.green
              : Colors.grey[700]!,
          width: 2,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아바타
            CircleAvatar(
              radius: 28,
              backgroundColor: member.isHost ? Colors.amber : Colors.blue,
              child: member.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        member.avatarUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),

            const SizedBox(height: 8),

            // 사용자 이름
            Text(
              member.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // 상태 배지
            _buildStatusBadge(),

            // 현재 사용자 표시
            if (isCurrentUser) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(Icons.person, size: 32, color: Colors.white);
  }

  Widget _buildStatusBadge() {
    final Color badgeColor;
    final String badgeText;

    if (member.isHost) {
      badgeColor = Colors.amber;
      badgeText = '방장';
    } else if (member.isReady) {
      badgeColor = Colors.green;
      badgeText = '준비 완료';
    } else {
      badgeColor = Colors.grey;
      badgeText = '대기 중';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
