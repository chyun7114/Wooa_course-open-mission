class RankingResponse {
  final String nickname;
  final int score;

  RankingResponse({required this.nickname, required this.score});

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    return RankingResponse(
      nickname: json['nickname'] as String? ?? 'Unknown',
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nickname': nickname, 'score': score};
  }
}

class UpsertRankingRequest {
  final int score;

  UpsertRankingRequest({required this.score});

  Map<String, dynamic> toJson() {
    return {'score': score};
  }
}
