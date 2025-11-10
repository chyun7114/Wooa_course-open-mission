import 'package:flutter/material.dart';

class GameConstants {

  // 보드 설정
  static const int boardWidth = 10;   
  static const int boardHeight = 20;

  // 게임 속도 및 점수 설정
  static const int initialSpeed = 800;    
  static const int minSpeed = 100;        
  static const int speedDecrease = 50;   
  
  static const int scorePerLine = 100;    
  static const int scorePerLevel = 1000;
  
  static const Map<int, Color> blockColors = {
    0: Colors.transparent,     // 빈 칸
    1: Colors.cyan,           // I 블록
    2: Colors.yellow,         // O 블록
    3: Colors.purple,         // T 블록
    4: Colors.green,          // S 블록
    5: Colors.red,            // Z 블록
    6: Colors.blue,           // J 블록
    7: Colors.orange,         // L 블록
  };
  
  // UI 설정
  static const double cellSize = 30.0;    // 각 셀의 크기 (픽셀)
  static const double borderWidth = 1.0;  // 셀 테두리 두께
}
