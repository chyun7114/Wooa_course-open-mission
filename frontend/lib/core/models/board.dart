import '../constants/game_constants.dart';

class Board {
  // 보드 크기 설정
  final int width;
  final int height;
  
  // 보드의 격자 상태
  late List<List<int>> grid;
  
  // 보드 생성자
  Board({
    this.width = GameConstants.boardWidth,
    this.height = GameConstants.boardHeight,
  }) {
    // 모든 칸이 비어있도록 보드 초기화
    grid = List.generate(
      height,
      (y) => List.filled(width, 0),
    );
  }
  
  // 주어진 좌표가 보드 내부에 있는지 확인
  bool isInside(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }
  
  // 특정 위치의 셀 값을 가져오기
  int getCell(int x, int y) {
    if (!isInside(x, y)) {
      return -1; // 보드 밖은 -1 반환
    }
    return grid[y][x];
  }
  
  // 특정 위치의 셀 값을 설정하기
  void setCell(int x, int y, int value) {
    if (isInside(x, y)) {
      grid[y][x] = value;
    }
  }
  
  // 특정 위치가 비어있는지 확인
  bool isEmpty(int x, int y) {
    return isInside(x, y) && grid[y][x] == 0;
  }
  
  // 특정 행(가로줄)이 가득 찼는지 확인
  bool isLineFull(int y) {
    if (y < 0 || y >= height) return false;
    
    // 한 칸이라도 비어있으면 false
    for (int x = 0; x < width; x++) {
      if (grid[y][x] == 0) {
        return false;
      }
    }
    return true;
  }
  
  // 가득 찬 줄을 제거하고 위의 줄들을 아래로 내리기
  int clearFullLines() {
    int clearedLines = 0;
    
    // 아래에서 위로 검사 (y = height-1 부터 0까지)
    for (int y = height - 1; y >= 0; y--) {
      if (isLineFull(y)) {
        // 가득 찬 줄 제거
        _removeLine(y);
        clearedLines++;
        y++; // 제거 후 같은 y를 다시 검사 (위의 줄이 내려왔으므로)
      }
    }
    
    return clearedLines;
  }
  
  // 특정 행을 제거하고 위의 모든 행을 한 칸씩 아래로 이동
  void _removeLine(int lineY) {
    // 제거할 줄 위의 모든 줄을 한 칸씩 아래로
    for (int y = lineY; y > 0; y--) {
      grid[y] = List.from(grid[y - 1]);
    }
    // 맨 위 줄은 빈 줄로 채우기
    grid[0] = List.filled(width, 0);
  }
  
  // 보드를 초기화
  void reset() {
    grid = List.generate(
      height,
      (y) => List.filled(width, 0),
    );
  }
  
  // 보드의 복사본 생성
  Board copy() {
    final newBoard = Board(width: width, height: height);
    for (int y = 0; y < height; y++) {
      newBoard.grid[y] = List.from(grid[y]);
    }
    return newBoard;
  }
  
  // 보드 상태를 문자열로 출력
  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Board ${width}x$height:');
    for (int y = 0; y < height; y++) {
      buffer.write('|');
      for (int x = 0; x < width; x++) {
        buffer.write(grid[y][x] == 0 ? '.' : grid[y][x]);
      }
      buffer.writeln('|');
    }
    return buffer.toString();
  }
}
