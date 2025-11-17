import 'package:flutter/foundation.dart';
import '../core/models/ranking_models.dart';
import '../core/services/ranking_service.dart';

class RankingProvider with ChangeNotifier {
  final RankingService _rankingService = RankingService();

  List<RankingResponse> _topRankings = [];
  RankingResponse? _myRanking;
  bool _isLoading = false;
  String? _errorMessage;

  List<RankingResponse> get topRankings => _topRankings;
  RankingResponse? get myRanking => _myRanking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 랭킹 등록/업데이트
  Future<bool> submitScore(int score) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _rankingService.upsertRanking(score);
      _myRanking = result;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Failed to submit score: $e');
      }
      return false;
    }
  }

  /// 전체 상위 랭킹 조회
  Future<void> fetchTopRankings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _topRankings = await _rankingService.getTopRankings();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Failed to fetch top rankings: $e');
      }
    }
  }

  /// 내 랭킹 조회
  Future<void> fetchMyRanking() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _myRanking = await _rankingService.getMyRanking();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Failed to fetch my ranking: $e');
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
