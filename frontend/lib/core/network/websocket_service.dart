import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // 개발 환경에 맞게 수정하세요
  static const String _baseUrl = kDebugMode
      ? 'http://localhost:3000'
      : 'https://distinctive-magdalene-chyun7114-f3225d28.koyeb.app';

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect(String userId, String nickname) {
    if (_socket != null && _isConnected) {
      debugPrint('WebSocket already connected');
      return;
    }

    debugPrint('🔌 Connecting to WebSocket: $_baseUrl/game');
    debugPrint('👤 User: $nickname ($userId)');

    _socket = IO.io(
      '$_baseUrl/game',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'foo': 'bar'})
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('✅ WebSocket connected');
      _isConnected = true;

      // 연결되면 바로 사용자 등록
      debugPrint('📤 Emitting register: userId=$userId, nickname=$nickname');
      _socket?.emit('register', {'userId': userId, 'nickname': nickname});
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
    });

    _socket?.connect();
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

  // 이벤트 리스너 등록
  void on(String event, Function(dynamic) handler) {
    debugPrint('👂 Listening to event: $event');
    _socket?.on(event, (data) {
      debugPrint('📥 Received [$event]: $data');
      handler(data);
    });
  }

  // 이벤트 리스너 제거
  void off(String event) {
    debugPrint('🔇 Removing listener: $event');
    _socket?.off(event);
  }

  // 이벤트 발생
  void emit(String event, dynamic data) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot emit $event: WebSocket not connected');
      return;
    }
    debugPrint('📤 Emitting [$event]: $data');
    _socket?.emit(event, data);
  }

  // 이벤트 발생 후 응답 받기
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
