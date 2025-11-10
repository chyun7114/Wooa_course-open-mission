enum TetrominoType {
  I, // 막대 모양 (하늘색)
  O, // 정사각형 모양 (노란색)
  T, // T자 모양 (보라색)
  S, // S자 모양 (초록색)
  Z, // Z자 모양 (빨간색)
  J, // J자 모양 (파란색)
  L, // L자 모양 (주황색)
}

class Tetromino {
  // 블록의 타입 (I, O, T, S, Z, J, L 중 하나)
  final TetrominoType type;
  
  // 블록 회전 상태 및 현재 좌표 선언
  int rotation;
  
  int x;
  int y;
  
  // 테트로미노 생성자
  Tetromino({
    required this.type,
    this.rotation = 0,
    this.x = 3,
    this.y = 0,
  });
  
  // 블록의 색상 코드를 반환 (1~7)
  int get colorCode {
    switch (type) {
      case TetrominoType.I:
        return 1;
      case TetrominoType.O:
        return 2;
      case TetrominoType.T:
        return 3;
      case TetrominoType.S:
        return 4;
      case TetrominoType.Z:
        return 5;
      case TetrominoType.J:
        return 6;
      case TetrominoType.L:
        return 7;
    }
  }
  
  // 현재 블록의 형태를 4x4 매트릭스로 반환
  List<List<int>> get shape {
    return _shapes[type]![rotation % 4];
  }
  
  // 블록을 시계방향으로 90도 회전
  void rotateClockwise() {
    rotation = (rotation + 1) % 4;
  }
  
  // 블록을 반시계방향으로 90도 회전
  void rotateCounterClockwise() {
    rotation = (rotation - 1) % 4;
    if (rotation < 0) rotation = 3;
  }
  
  // 블록을 왼쪽으로 이동
  void moveLeft() {
    x--;
  }
  
  // 블록을 오른쪽으로 이동
  void moveRight() {
    x++;
  }
  
  // 블록을 아래로 이동
  void moveDown() {
    y++;
  }
  
  // 블록을 위로 이동
  void moveUp() {
    y--;
  }
  
  // 블록의 복사본 생성
  Tetromino copy() {
    return Tetromino(
      type: type,
      rotation: rotation,
      x: x,
      y: y,
    );
  }
  
  // 블록이 차지하는 실제 셀 좌표들을 반환
  List<Position> get positions {
    List<Position> result = [];
    final matrix = shape;
    
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (matrix[row][col] == 1) {
          result.add(Position(x + col, y + row));
        }
      }
    }
    
    return result;
  }
  
  static final Map<TetrominoType, List<List<List<int>>>> _shapes = {
    // I 블록 (막대)
    TetrominoType.I: [
      // 0도: 가로
      [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      // 90도: 세로
      [
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
      ],
      // 180도: 가로 (0도와 동일하지만 위치 다름)
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
      ],
      // 270도: 세로 (90도와 동일하지만 위치 다름)
      [
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
    
    // O 블록 (정사각형) - 회전해도 모양이 같음
    TetrominoType.O: [
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
    ],
    
    // T 블록
    TetrominoType.T: [
      // 0도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [1, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      // 90도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 0, 0],
      ],
      // 180도
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 0],
        [0, 1, 0, 0],
      ],
      // 270도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [1, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
    
    // S 블록
    TetrominoType.S: [
      // 0도
      [
        [0, 0, 0, 0],
        [0, 0, 1, 1],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      // 90도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 1, 0],
      ],
      // 180도
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 1, 1],
        [0, 1, 1, 0],
      ],
      // 270도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 1, 0],
      ],
    ],
    
    // Z 블록
    TetrominoType.Z: [
      // 0도
      [
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      // 90도
      [
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 1, 0],
        [0, 1, 0, 0],
      ],
      // 180도
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 1, 1, 0],
      ],
      // 270도
      [
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 1, 0],
        [0, 1, 0, 0],
      ],
    ],
    
    // J 블록
    TetrominoType.J: [
      // 0도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 1],
        [0, 0, 0, 0],
      ],
      // 90도
      [
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 1, 1, 0],
      ],
      // 180도
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 0],
        [0, 0, 1, 0],
      ],
      // 270도
      [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
    
    // L 블록
    TetrominoType.L: [
      // 0도
      [
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [1, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      // 90도
      [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 0],
      ],
      // 180도
      [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [1, 1, 1, 0],
        [1, 0, 0, 0],
      ],
      // 270도
      [
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
      ],
    ],
  };
}

class Position {
  final int x;
  final int y;
  
  Position(this.x, this.y);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  
  @override
  String toString() => '($x, $y)';
}
