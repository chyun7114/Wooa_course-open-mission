import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthStorageService {
  static final AuthStorageService _instance = AuthStorageService._internal();
  factory AuthStorageService() => _instance;
  AuthStorageService._internal();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyNickname = 'nickname';

  SharedPreferences? _prefs;

  // SharedPreferences 초기화 (내부적으로 이미 초기화되었는지 확인)
  Future<void> init() async {
    if (_prefs != null) {
      debugPrint('🔐 AuthStorageService already initialized');
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    debugPrint('🔐 AuthStorageService initialized');
  }

  // _prefs가 초기화되지 않았으면 자동으로 초기화
  Future<SharedPreferences> get _ensureInitialized async {
    if (_prefs == null) {
      debugPrint('⚠️ AuthStorageService not initialized, initializing now...');
      await init();
    }
    return _prefs!;
  }

  // Access Token 저장
  Future<void> saveAccessToken(String token) async {
    final prefs = await _ensureInitialized;
    await prefs.setString(_keyAccessToken, token);
    debugPrint('💾 Access Token saved');
  }

  // Access Token 가져오기 (비동기로 변경)
  Future<String?> getAccessToken() async {
    final prefs = await _ensureInitialized;
    final token = prefs.getString(_keyAccessToken);
    debugPrint(
      '🔑 Access Token retrieved: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL"}',
    );
    return token;
  }

  // Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    final prefs = await _ensureInitialized;
    await prefs.setString(_keyRefreshToken, token);
    debugPrint('💾 Refresh Token saved');
  }

  // Refresh Token 가져오기 (비동기로 변경)
  Future<String?> getRefreshToken() async {
    final prefs = await _ensureInitialized;
    final token = prefs.getString(_keyRefreshToken);
    debugPrint(
      '🔑 Refresh Token retrieved: ${token != null ? "EXISTS" : "NULL"}',
    );
    return token;
  }

  // User ID 저장
  Future<void> saveUserId(String userId) async {
    final prefs = await _ensureInitialized;
    await prefs.setString(_keyUserId, userId);
    debugPrint('💾 User ID saved: $userId');
  }

  // User ID 가져오기 (비동기로 변경)
  Future<String?> getUserId() async {
    final prefs = await _ensureInitialized;
    final userId = prefs.getString(_keyUserId);
    debugPrint('👤 User ID retrieved: $userId');
    return userId;
  }

  // Nickname 저장
  Future<void> saveNickname(String nickname) async {
    final prefs = await _ensureInitialized;
    await prefs.setString(_keyNickname, nickname);
    debugPrint('💾 Nickname saved: $nickname');
  }

  // Nickname 가져오기 (비동기로 변경)
  Future<String?> getNickname() async {
    final prefs = await _ensureInitialized;
    final nickname = prefs.getString(_keyNickname);
    debugPrint('👤 Nickname retrieved: $nickname');
    return nickname;
  }

  // 모든 인증 정보 저장
  Future<void> saveAuthData({
    required String accessToken,
    String? refreshToken,
    required String userId,
    required String nickname,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      if (refreshToken != null) saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveNickname(nickname),
    ]);
    debugPrint('💾 All auth data saved');
  }

  // 로그인 여부 확인 (비동기로 변경)
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final hasToken = token != null;
    debugPrint('🔐 Is logged in: $hasToken');
    return hasToken;
  }

  // 모든 인증 정보 삭제 (로그아웃)
  Future<void> clearAuthData() async {
    final prefs = await _ensureInitialized;
    await Future.wait([
      prefs.remove(_keyAccessToken),
      prefs.remove(_keyRefreshToken),
      prefs.remove(_keyUserId),
      prefs.remove(_keyNickname),
    ]);
    debugPrint('🗑️ All auth data cleared');
  }

  // 전체 스토리지 초기화
  Future<void> clearAll() async {
    final prefs = await _ensureInitialized;
    await prefs.clear();
    debugPrint('🗑️ All storage cleared');
  }
}
