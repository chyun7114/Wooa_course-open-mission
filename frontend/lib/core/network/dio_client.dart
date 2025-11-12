import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  static String get _baseUrl {
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
