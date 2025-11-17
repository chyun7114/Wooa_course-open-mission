import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../services/auth_storage_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  static const String _baseUrl = kDebugMode
      ? 'http://localhost:3000'
      : 'https://tetris-server.p-e.kr';

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      debugPrint('✅ WebSocket already connected');
      return;
    }

    final token = await AuthStorageService().getAccessToken();
    final userId = await AuthStorageService().getUserId();
    final nickname = await AuthStorageService().getNickname();

    if (token == null || userId == null || nickname == null) {
      debugPrint('❌ Cannot connect WebSocket: Missing auth data');
      debugPrint('   Token: ${token != null ? "exists" : "null"}');
      debugPrint('   UserId: $userId');
      debugPrint('   Nickname: $nickname');
      return;
    }

    debugPrint('🔌 Connecting to WebSocket: $_baseUrl/game');
    debugPrint('👤 User: $nickname ($userId)');
    debugPrint('🔑 Token: ${token.substring(0, 20)}...');

    _socket = IO.io(
      '$_baseUrl/game',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    final completer = Completer<void>();

    _socket?.onConnect((_) {
      debugPrint('✅ WebSocket connected with JWT authentication');
      _isConnected = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('❌ WebSocket disconnected');
      _isConnected = false;
    });

    _socket?.onError((error) {
      debugPrint('🔴 WebSocket error: $error');
    });

    _socket?.onConnectError((error) {
      debugPrint('🔴 WebSocket connect error: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });

    _socket?.connect();

    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ WebSocket connection timeout');
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to connect WebSocket: $e');
    }
  }

  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting WebSocket');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  void on(String event, Function(dynamic) handler) {
    debugPrint('👂 Listening to event: $event');
    _socket?.on(event, (data) {
      debugPrint('📥 Received [$event]: $data');
      handler(data);
    });
  }

  void off(String event) {
    debugPrint('🔇 Removing listener: $event');
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot emit $event: WebSocket not connected');
      return;
    }
    debugPrint('📤 Emitting [$event]: $data');
    _socket?.emit(event, data);
  }

  void emitWithAck(String event, dynamic data, Function(dynamic) ack) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot emit $event: WebSocket not connected');
      return;
    }
    debugPrint('📤 Emitting with ACK [$event]: $data');
    _socket?.emitWithAck(
      event,
      data,
      ack: (response) {
        debugPrint('📥 ACK Response [$event]: $response');
        ack(response);
      },
    );
  }
}
