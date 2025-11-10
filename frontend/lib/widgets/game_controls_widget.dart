import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameControlsWidget extends StatefulWidget {
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onMoveDown;
  final VoidCallback onRotate;
  final VoidCallback onHardDrop;
  final VoidCallback onPause;
  final VoidCallback? onStart;
  final VoidCallback? onHold;

  const GameControlsWidget({
    super.key,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onMoveDown,
    required this.onRotate,
    required this.onHardDrop,
    required this.onPause,
    this.onStart,
    this.onHold,
  });

  @override
  State<GameControlsWidget> createState() => _GameControlsWidgetState();
}

class _GameControlsWidgetState extends State<GameControlsWidget> {
  final Map<LogicalKeyboardKey, Timer?> _keyTimers = {};
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  static const Duration _initialDelay = Duration(milliseconds: 200);
  static const Duration _repeatInterval = Duration(milliseconds: 50);

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    for (var timer in _keyTimers.values) {
      timer?.cancel();
    }
    _keyTimers.clear();
    _pressedKeys.clear();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: const SizedBox.shrink(),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _handleKeyDown(event);
    } else if (event is KeyUpEvent) {
      _handleKeyUp(event);
    }
  }

  void _handleKeyDown(KeyDownEvent event) {
    final key = event.logicalKey;

    if (_pressedKeys.contains(key)) return;
    _pressedKeys.add(key);

    _executeKeyAction(key);

    if (_isRepeatableKey(key)) {
      _keyTimers[key] = Timer(_initialDelay, () {
        _keyTimers[key] = Timer.periodic(_repeatInterval, (timer) {
          if (_pressedKeys.contains(key)) {
            _executeKeyAction(key);
          } else {
            timer.cancel();
          }
        });
      });
    }
  }

  void _handleKeyUp(KeyUpEvent event) {
    final key = event.logicalKey;
    _pressedKeys.remove(key);
    _keyTimers[key]?.cancel();
    _keyTimers.remove(key);
  }

  bool _isRepeatableKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown;
  }

  void _executeKeyAction(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.enter:
        widget.onStart?.call();
        break;
      case LogicalKeyboardKey.arrowLeft:
        widget.onMoveLeft();
        break;
      case LogicalKeyboardKey.arrowRight:
        widget.onMoveRight();
        break;
      case LogicalKeyboardKey.arrowDown:
        widget.onMoveDown();
        break;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyX:
        widget.onRotate();
        break;
      case LogicalKeyboardKey.space:
        widget.onHardDrop();
        break;
      case LogicalKeyboardKey.keyP:
      case LogicalKeyboardKey.escape:
        widget.onPause();
        break;
      case LogicalKeyboardKey.keyC:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        widget.onHold?.call();
        break;
    }
  }
}
