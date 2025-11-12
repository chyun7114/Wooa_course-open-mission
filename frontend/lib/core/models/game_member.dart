class GameMember {
  final String id;
  final String username;
  final bool isHost;
  final bool isReady;
  final String? avatarUrl;

  GameMember({
    required this.id,
    required this.username,
    required this.isHost,
    this.isReady = false,
    this.avatarUrl,
  });

  factory GameMember.fromJson(Map<String, dynamic> json) {
    return GameMember(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      isHost: json['isHost'] ?? false,
      isReady: json['isReady'] ?? false,
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'isHost': isHost,
      'isReady': isReady,
      'avatarUrl': avatarUrl,
    };
  }

  GameMember copyWith({
    String? id,
    String? username,
    bool? isHost,
    bool? isReady,
    String? avatarUrl,
  }) {
    return GameMember(
      id: id ?? this.id,
      username: username ?? this.username,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
