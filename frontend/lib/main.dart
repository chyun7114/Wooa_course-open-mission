import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/room_waiting_provider.dart';
import 'providers/multiplayer_game_provider.dart';
import 'providers/ranking_provider.dart';
import 'screens/auth/login_screen.dart';
import 'core/services/auth_storage_service.dart';
import 'core/network/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthStorageService 초기화
  await AuthStorageService().init();

  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => RoomWaitingProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
        ChangeNotifierProxyProvider<GameProvider, MultiplayerGameProvider>(
          create: (context) => MultiplayerGameProvider(
            WebSocketService(),
            gameProvider: context.read<GameProvider>(),
          ),
          update: (context, gameProvider, previous) =>
              previous ??
              MultiplayerGameProvider(
                WebSocketService(),
                gameProvider: gameProvider,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Tetris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
