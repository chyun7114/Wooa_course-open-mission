import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_storage_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final AuthStorageService _authStorage = AuthStorageService();

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
        onRequest: (options, handler) async {
          // 자동으로 토큰 추가 (비동기로 변경)
          final token = await _authStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              debugPrint('🔑 Token added to request');
            }
          }

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

          // 401 Unauthorized - 토큰 만료
          if (error.response?.statusCode == 401) {
            debugPrint('🔐 Token expired or invalid');
            // TODO: 토큰 갱신 또는 로그아웃 처리
          }

          return handler.next(error);
        },
      ),
    );
  }

  // 수동으로 토큰 설정 (로그인 후)
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('🔑 Token manually set');
  }

  // 토큰 제거 (로그아웃)
  void removeToken() {
    dio.options.headers.remove('Authorization');
    debugPrint('🔓 Token removed');
  }
}
