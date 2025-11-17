import 'package:dio/dio.dart';
import '../models/ranking_models.dart';
import '../network/dio_client.dart';

class RankingService {
  final DioClient _dioClient = DioClient();

  Future<RankingResponse> upsertRanking(int score) async {
    try {
      final response = await _dioClient.dio.post(
        '/ranking',
        data: UpsertRankingRequest(score: score).toJson(),
      );

      final responseData = response.data;
      final data = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      if (data is List && data.isNotEmpty) {
        return RankingResponse.fromJson(data[0]);
      }

      return RankingResponse.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<RankingResponse>> getTopRankings() async {
    try {
      print('🌐 API Call: GET /ranking/top');
      final response = await _dioClient.dio.get('/ranking/top');
      print('📥 Top rankings response: ${response.data}');

      final responseData = response.data;
      final data = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      print('📋 Parsed data: $data');

      final List<dynamic> listData = data as List<dynamic>;
      final rankings = listData.map((json) {
        print('🔍 Parsing item: $json');
        return RankingResponse.fromJson(json);
      }).toList();

      print('✅ ${rankings.length} rankings loaded');
      return rankings;
    } on DioException catch (e) {
      print('❌ DioException in getTopRankings: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('❌ Unexpected error in getTopRankings: $e');
      rethrow;
    }
  }

  Future<RankingResponse?> getMyRanking() async {
    try {
      final response = await _dioClient.dio.get('/ranking/my');
      final responseData = response.data;
      final data = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      if (data is List && data.isEmpty) {
        return null;
      }

      if (data is List && data.isNotEmpty) {
        return RankingResponse.fromJson(data[0]);
      }

      return RankingResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// 에러 핸들링
  String _handleError(DioException error) {
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (data is Map && data['message'] != null) {
          errorMessage = data['message'];
        } else {
          errorMessage = _getErrorMessageByStatusCode(statusCode);
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = '요청이 취소되었습니다.';
        break;
      default:
        errorMessage = '네트워크 연결을 확인해주세요.';
    }

    return errorMessage;
  }

  String _getErrorMessageByStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '로그인이 필요합니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '랭킹 정보를 찾을 수 없습니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      default:
        return '오류가 발생했습니다.';
    }
  }
}
