import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../models/room_model.dart';

class RoomApiService {
  final Dio _dio = DioClient().dio;

  // 방 목록 조회
  Future<List<RoomModel>> getRoomList() async {
    try {
      final response = await _dio.get('/rooms');

      if (response.data['code'] == 200) {
        final List<dynamic> rooms = response.data['data'] ?? [];
        return rooms.map((json) => RoomModel.fromJson(json)).toList();
      }

      throw Exception(response.data['message'] ?? '방 목록 조회 실패');
    } catch (e) {
      rethrow;
    }
  }

  // 방 상세 정보 조회
  Future<RoomModel> getRoomDetail(String roomId) async {
    try {
      final response = await _dio.get('/rooms/$roomId');

      if (response.data['code'] == 200) {
        return RoomModel.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? '방 정보 조회 실패');
    } catch (e) {
      rethrow;
    }
  }

  // 통계 조회
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/rooms/stats/summary');

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw Exception(response.data['message'] ?? '통계 조회 실패');
    } catch (e) {
      rethrow;
    }
  }
}
