import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/websocket_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/multiplayer_game_provider.dart';
import 'multiplayer_game_screen.dart';

/// Flutter Preview를 위한 MultiplayerGameScreen 프리뷰
/// 
/// 실행 방법:
/// flutter run -t lib/screens/game/multiplayer_game_screen_preview.dart -d chrome

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PreviewSelector(),
    );
  }
}

class PreviewSelector extends StatefulWidget {
  const PreviewSelector({super.key});

  @override
  State<PreviewSelector> createState() => _PreviewSelectorState();
}

class _PreviewSelectorState extends State<PreviewSelector> {
  String selectedPreview = '2players';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멀티플레이 화면 프리뷰'),
        actions: [
          DropdownButton<String>(
            value: selectedPreview,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: '2players', child: Text('2명 대전')),
              DropdownMenuItem(value: '4players', child: Text('4명 대전')),
              DropdownMenuItem(value: '6players', child: Text('6명 대전')),
              DropdownMenuItem(value: '8players', child: Text('8명 대전')),
              DropdownMenuItem(value: 'gameover', child: Text('게임 오버 (순위)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedPreview = value;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildPreview(),
    );
  }

  Widget _buildPreview() {
    switch (selectedPreview) {
      case '2players':
        return _buildMultiplayerPreview(2);
      case '4players':
        return _buildMultiplayerPreview(4);
      case '6players':
        return _buildMultiplayerPreview(6);
      case '8players':
        return _buildMultiplayerPreview(8);
      case 'gameover':
        return _buildGameOverPreview();
      default:
        return _buildMultiplayerPreview(2);
    }
  }

  Widget _buildMultiplayerPreview(int playerCount) {
    final players = List.generate(
      playerCount,
      (i) => {
        'playerId': 'player-${i + 1}',
        'nickname': 'Player ${i + 1}',
      },
    );

    return MultiProviderWrapper(
      opponentCount: playerCount - 1,
      isGameEnded: false,
      child: MultiplayerGameScreen(
        roomId: 'preview-room-$playerCount',
        myPlayerId: 'player-1',
        players: players,
      ),
    );
  }

  Widget _buildGameOverPreview() {
    return MultiProviderWrapper(
      opponentCount: 3,
      isGameEnded: true,
      child: const MultiplayerGameScreen(
        roomId: 'preview-room-gameover',
        myPlayerId: 'player-1',
        players: [
          {'playerId': 'player-1', 'nickname': 'You'},
          {'playerId': 'player-2', 'nickname': 'Player 2'},
          {'playerId': 'player-3', 'nickname': 'Player 3'},
          {'playerId': 'player-4', 'nickname': 'Player 4'},
        ],
      ),
    );
  }
}

/// Mock Provider 래퍼
class MultiProviderWrapper extends StatelessWidget {
  final Widget child;
  final int opponentCount;
  final bool isGameEnded;

  const MultiProviderWrapper({
    super.key,
    required this.child,
    this.opponentCount = 1,
    this.isGameEnded = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ),
        ChangeNotifierProxyProvider<GameProvider, MultiplayerGameProvider>(
          create: (context) {
            final provider = MultiplayerGameProvider(
              WebSocketService(),
              gameProvider: context.read<GameProvider>(),
            );
            provider.setMockData(
              opponentCount: opponentCount,
              isGameEnded: isGameEnded,
            );
            return provider;
          },
          update: (context, gameProvider, previous) =>
              previous ?? 
              MultiplayerGameProvider(
                WebSocketService(),
                gameProvider: gameProvider,
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: child,
      ),
    );
  }
}
