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
    // 개발 환경에서는 localhost 사용
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
          if (kDebugMode) {
            debugPrint('🌐 [${options.method}] ${options.uri}');
            debugPrint('📤 Request Data: ${options.data}');
            debugPrint('📋 Request Headers: ${options.headers}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '✅ [${response.statusCode}] ${response.requestOptions.uri}',
            );
            debugPrint('📥 Response Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint(
              '🔴 [${error.response?.statusCode}] ${error.requestOptions.uri}',
            );
            debugPrint('❌ Error: ${error.message}');
            debugPrint('📥 Error Response: ${error.response?.data}');
          }
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
