import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../network/dio_client.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  // 회원가입
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/member/sign-up',
        data: request.toJson(),
      );

      return SignUpResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 로그인
  Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/member/sign-in',
        data: request.toJson(),
      );

      final signInResponse = SignInResponse.fromJson(response.data);

      // 토큰이 있으면 저장
      if (signInResponse.accessToken != null) {
        _dioClient.setToken(signInResponse.accessToken!);
      }

      return signInResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 로그아웃
  void logout() {
    _dioClient.removeToken();
  }

  // 에러 핸들링
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
        return '인증에 실패했습니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 409:
        return '이미 존재하는 정보입니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      default:
        return '오류가 발생했습니다.';
    }
  }
}

