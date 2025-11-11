import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/game_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // .env 파일이 있을 때만 로드 (개발 환경)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env 파일이 없어도 계속 진행 (프로덕션 환경)
    print('기본 설정을 사용합니다.');
  }
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
