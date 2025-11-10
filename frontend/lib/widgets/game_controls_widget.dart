import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameControlsWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: const SizedBox.shrink(),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
        onStart?.call();
        break;
      case LogicalKeyboardKey.arrowLeft:
        onMoveLeft();
        break;
      case LogicalKeyboardKey.arrowRight:
        onMoveRight();
        break;
      case LogicalKeyboardKey.arrowDown:
        onMoveDown();
        break;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyX:
        onRotate();
        break;
      case LogicalKeyboardKey.space:
        onHardDrop();
        break;
      case LogicalKeyboardKey.keyP:
      case LogicalKeyboardKey.escape:
        onPause();
        break;
      case LogicalKeyboardKey.keyC:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        onHold?.call();
        break;
    }
  }
}
