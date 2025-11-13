class RoomModel {
  final String id;
  final String name;
  final String hostName;
  final int currentPlayers;
  final int maxPlayers;
  final bool isPrivate;
  final bool isPlaying;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.hostName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.isPrivate,
    required this.isPlaying,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['title'] ?? json['name'] ?? '',
      hostName: json['hostNickname'] ?? json['hostName'] ?? '',
      currentPlayers: json['currentPlayers'] ?? 0,
      maxPlayers: json['maxPlayers'] ?? 2,
      isPrivate: json['isPrivate'] ?? false,
      isPlaying: json['isPlaying'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'hostNickname': hostName,
      'currentPlayers': currentPlayers,
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'isPlaying': isPlaying,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get canJoin => !isFull && !isPlaying;

  String get status {
    if (isPlaying) return 'playing';
    if (isFull) return 'full';
    return 'waiting';
  }
}
