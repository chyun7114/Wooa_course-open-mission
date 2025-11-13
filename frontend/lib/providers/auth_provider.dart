import 'package:flutter/material.dart';
import '../core/models/auth_models.dart';
import '../core/services/auth_service.dart';
import '../core/services/auth_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthStorageService _authStorage = AuthStorageService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;

  // 회원가입
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = SignUpRequest(
        username: username,
        email: email,
        password: password,
      );

      final response = await _authService.signUp(request);

      _isLoading = false;
      notifyListeners();

      return response.success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그인
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = SignInRequest(email: email, password: password);

      final response = await _authService.signIn(request);

      if (response.success && response.accessToken != null) {
        _accessToken = response.accessToken;
        _isAuthenticated = true;

        // ✅ AuthStorageService에 토큰과 사용자 정보 저장
        await _authStorage.saveAuthData(
          accessToken: response.accessToken!,
          userId: response.userId?.toString() ?? '',
          nickname: response.username ?? '',
        );

        debugPrint('✅ Login successful, token and user data saved');
      }

      _isLoading = false;
      notifyListeners();

      return response.success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _authService.logout();
    await _authStorage.clearAuthData(); // ✅ 저장된 토큰도 삭제
    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();
    debugPrint('✅ Logged out, all auth data cleared');
  }

  // 에러 메시지 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
