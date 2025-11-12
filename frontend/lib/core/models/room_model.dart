class RoomModel {
  final String id;
  final String name;
  final String hostName;
  final int currentPlayers;
  final int maxPlayers;
  final String status; // 'waiting', 'playing', 'full'
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.hostName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.status,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hostName: json['hostName'] ?? '',
      currentPlayers: json['currentPlayers'] ?? 0,
      maxPlayers: json['maxPlayers'] ?? 2,
      status: json['status'] ?? 'waiting',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostName': hostName,
      'currentPlayers': currentPlayers,
      'maxPlayers': maxPlayers,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get isPlaying => status == 'playing';
  bool get canJoin => !isFull && !isPlaying;
}
