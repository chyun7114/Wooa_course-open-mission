import 'dart:async';

class GameTimer {
  Timer? _timer;
  
  bool get isRunning => _timer != null && _timer!.isActive;
  
  void start(int speed, void Function() onTick) {
    stop();
    
    _timer = Timer.periodic(
      Duration(milliseconds: speed),
      (_) => onTick(),
    );
  }
  
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
  
  void restart(int speed, void Function() onTick) {
    start(speed, onTick);
  }
  
  void dispose() {
    stop();
  }
}
