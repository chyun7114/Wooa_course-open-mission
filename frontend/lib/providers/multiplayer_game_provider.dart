import 'package:flutter/material.dart';
import '../core/network/websocket_service.dart';

/// 플레이어 게임 상태
class PlayerGameState {
  final String playerId;
  final String nickname;
  final bool isAlive;
  final int rank;
  final int score;
  final int level;
  final int linesCleared;
  final List<List<int>>? board; // 테트리스 보드 데이터

  PlayerGameState({
    required this.playerId,
    required this.nickname,
    required this.isAlive,
    required this.rank,
    required this.score,
    required this.level,
    required this.linesCleared,
    this.board,
  });

  factory PlayerGameState.fromJson(Map<String, dynamic> json) {
    List<List<int>>? board;
    if (json['board'] != null) {
      board = (json['board'] as List)
          .map((row) => (row as List).map((cell) => cell as int).toList())
          .toList();
    }

    return PlayerGameState(
      playerId: json['playerId'] ?? '',
      nickname: json['nickname'] ?? '',
      isAlive: json['isAlive'] ?? true,
      rank: json['rank'] ?? 0,
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      linesCleared: json['linesCleared'] ?? 0,
      board: board,
    );
  }

  PlayerGameState copyWith({
    String? playerId,
    String? nickname,
    bool? isAlive,
    int? rank,
    int? score,
    int? level,
    int? linesCleared,
    List<List<int>>? board,
  }) {
    return PlayerGameState(
      playerId: playerId ?? this.playerId,
      nickname: nickname ?? this.nickname,
      isAlive: isAlive ?? this.isAlive,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      level: level ?? this.level,
      linesCleared: linesCleared ?? this.linesCleared,
      board: board ?? this.board,
    );
  }
}

/// 멀티플레이 게임 전체 상태
class MultiplayerGameState {
  final String roomId;
  final Map<String, PlayerGameState> players;
  final bool isGameEnded;
  final List<PlayerGameState>? finalRanking;

  MultiplayerGameState({
    required this.roomId,
    required this.players,
    this.isGameEnded = false,
    this.finalRanking,
  });

  MultiplayerGameState copyWith({
    String? roomId,
    Map<String, PlayerGameState>? players,
    bool? isGameEnded,
    List<PlayerGameState>? finalRanking,
  }) {
    return MultiplayerGameState(
      roomId: roomId ?? this.roomId,
      players: players ?? this.players,
      isGameEnded: isGameEnded ?? this.isGameEnded,
      finalRanking: finalRanking ?? this.finalRanking,
    );
  }
}

/// 멀티플레이 게임 상태 관리 Provider
class MultiplayerGameProvider with ChangeNotifier {
  final WebSocketService _wsService;
  MultiplayerGameState? _gameState;
  String? _myPlayerId;
  int _incomingAttackLines = 0;

  MultiplayerGameProvider(this._wsService);

  MultiplayerGameState? get gameState => _gameState;
  String? get myPlayerId => _myPlayerId;
  int get incomingAttackLines => _incomingAttackLines;

  /// 내 플레이어 상태
  PlayerGameState? get myPlayerState {
    if (_gameState == null || _myPlayerId == null) return null;
    return _gameState!.players[_myPlayerId];
  }

  /// 살아있는 플레이어 목록
  List<PlayerGameState> get alivePlayers {
    if (_gameState == null) return [];
    return _gameState!.players.values.where((p) => p.isAlive).toList();
  }

  /// 죽은 플레이어 목록 (순위순)
  List<PlayerGameState> get deadPlayers {
    if (_gameState == null) return [];
    final dead = _gameState!.players.values.where((p) => !p.isAlive).toList();
    dead.sort((a, b) => a.rank.compareTo(b.rank));
    return dead;
  }

  /// 게임 초기화 및 WebSocket 리스너 등록
  void initGame(
    String roomId,
    String myPlayerId,
    List<Map<String, dynamic>> players,
  ) {
    _myPlayerId = myPlayerId;

    final playerStates = <String, PlayerGameState>{};
    for (var player in players) {
      final playerId = player['id']?.toString() ?? '';
      final state = PlayerGameState(
        playerId: playerId,
        nickname: player['nickname'],
        isAlive: true,
        rank: 0,
        score: 0,
        level: 1,
        linesCleared: 0,
      );
      playerStates[playerId] = state;
    }

    _gameState = MultiplayerGameState(roomId: roomId, players: playerStates);

    _setupListeners();
    notifyListeners();
  }

  /// WebSocket 리스너 설정
  void _setupListeners() {
    // 게임 상태 업데이트
    _wsService.on('gameStateUpdated', (data) {
      if (data == null || _gameState == null) return;

      final playerId = data['playerId']?.toString();
      final score = data['score'] as int?;
      final level = data['level'] as int?;
      final linesCleared = data['linesCleared'] as int?;

      List<List<int>>? board;
      if (data['board'] != null) {
        try {
          board = (data['board'] as List)
              .map((row) => (row as List).map((cell) => cell as int).toList())
              .toList();
        } catch (e) {
          debugPrint('Board parsing error: $e');
        }
      }

      if (playerId != null && _gameState!.players.containsKey(playerId)) {
        final current = _gameState!.players[playerId]!;
        final updated = current.copyWith(
          score: score ?? current.score,
          level: level ?? current.level,
          linesCleared: linesCleared ?? current.linesCleared,
          board: board ?? current.board,
        );

        _gameState = _gameState!.copyWith(
          players: Map.from(_gameState!.players)..[playerId] = updated,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });

    // 공격 받음
    _wsService.on('attacked', (data) {
      if (data == null) return;

      final targetIdRaw = data['targetId'];
      final targetId = targetIdRaw?.toString();
      final attackLines = data['attackLines'] as int? ?? 0;

      if (targetId == _myPlayerId && attackLines > 0) {
        _incomingAttackLines += attackLines;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });

        // 3초 후 공격 표시 제거
        Future.delayed(const Duration(seconds: 3), () {
          if (_incomingAttackLines >= attackLines) {
            _incomingAttackLines -= attackLines;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifyListeners();
            });
          }
        });
      }
    });

    // 플레이어 게임 오버
    _wsService.on('playerGameOver', (data) {
      if (data == null || _gameState == null) return;

      final playerIdRaw = data['playerId'];
      final playerId = playerIdRaw?.toString();
      final rank = data['rank'] as int?;

      if (playerId != null && _gameState!.players.containsKey(playerId)) {
        final current = _gameState!.players[playerId]!;
        _gameState = _gameState!.copyWith(
          players: Map.from(_gameState!.players)
            ..[playerId] = current.copyWith(
              isAlive: false,
              rank: rank ?? current.rank,
            ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });

    // 게임 종료
    _wsService.on('gameEnded', (data) {
      if (data == null || _gameState == null) return;

      final rankingData = data['ranking'] as List<dynamic>?;
      if (rankingData != null) {
        final ranking = rankingData
            .map((r) => PlayerGameState.fromJson(r as Map<String, dynamic>))
            .toList();
        _gameState = _gameState!.copyWith(
          isGameEnded: true,
          finalRanking: ranking,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
  }

  /// 게임 상태 업데이트 전송
  void updateGameState({
    required int score,
    required int level,
    required int linesCleared,
    List<List<int>>? board,
  }) {
    if (_gameState == null) return;

    final payload = {
      'roomId': _gameState!.roomId,
      'score': score,
      'level': level,
      'linesCleared': linesCleared,
    };

    if (board != null) {
      payload['board'] = board;
    }

    _wsService.emit('updateGameState', payload);
  }

  /// 공격 전송 (라인 클리어 시)
  void sendAttack(int clearedLines) {
    if (_gameState == null || clearedLines < 2) return;

    _wsService.emit('attack', {
      'roomId': _gameState!.roomId,
      'clearedLines': clearedLines,
    });
  }

  /// 게임 오버
  void gameOver() {
    if (_gameState == null) return;

    _wsService.emit('gameOver', {'roomId': _gameState!.roomId});
  }

  /// 게임 포기
  void forfeit() {
    if (_gameState == null) return;

    _wsService.emit('forfeit', {'roomId': _gameState!.roomId});
  }

  /// 공격 라인 소비 (실제 게임에서 받은 라인 처리 후 호출)
  void consumeAttackLines(int lines) {
    if (_incomingAttackLines >= lines) {
      _incomingAttackLines -= lines;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// 초기화
  @override
  void dispose() {
    _wsService.off('gameStateUpdated');
    _wsService.off('attacked');
    _wsService.off('playerGameOver');
    _wsService.off('gameEnded');
    super.dispose();
  }
}
