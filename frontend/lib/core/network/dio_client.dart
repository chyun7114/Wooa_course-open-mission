import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  // 환경에 따른 기본 URL 반환
  static String get _baseUrl {
    // GitHub Pages 배포 환경에서는 실제 백엔드 URL 사용
    if (kReleaseMode) {
      return 'https://your-backend-url.com';
    }
    // 개발 환경에서는 .env 파일 또는 기본값 사용
    return dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 인터셉터 추가 (로깅, 토큰 자동 추가 등)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // 토큰 설정
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 토큰 제거
  void removeToken() {
    dio.options.headers.remove('Authorization');
  }
}
