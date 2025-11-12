import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  static String get _baseUrl {
    // 프로덕션(릴리즈 모드): 실제 배포된 백엔드 URL
    if (kReleaseMode) {
      return 'https://distinctive-magdalene-chyun7114-f3225d28.koyeb.app';
    }
<<<<<<< HEAD
    // 개발 환경: 로컬 백엔드
=======
    // 개발 환경에서는 localhost 사용
>>>>>>> ea8d870 (Feat(Front): 멀티플레이 방 리스트 UI 구현)
    return 'http://localhost:3000';
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
