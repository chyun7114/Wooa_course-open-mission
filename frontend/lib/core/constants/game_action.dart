import 'package:flutter/material.dart';
import 'package:frontend/core/constants/game_intent.dart';
import 'package:frontend/providers/game_provider.dart';
import 'package:provider/provider.dart';

class _GameAction<T extends Intent> extends Action<T> {
  _GameAction(this.context, this.callback);

  final BuildContext context;
  final void Function(GameProvider) callback;

  @override
  void invoke(T intent) {
    callback(context.read<GameProvider>());
  }
}

class MoveLeftAction extends _GameAction<MoveLeftIntent> {
  MoveLeftAction(BuildContext context)
    : super(context, (provider) => provider.moveLeft());
}

class MoveRightAction extends _GameAction<MoveRightIntent> {
  MoveRightAction(BuildContext context)
    : super(context, (provider) => provider.moveRight());
}

class MoveDownAction extends _GameAction<MoveDownIntent> {
  MoveDownAction(BuildContext context)
    : super(context, (provider) => provider.moveDown());
}

class RotateAction extends _GameAction<RotateIntent> {
  RotateAction(BuildContext context)
    : super(context, (provider) => provider.rotate());
}

class HardDropAction extends _GameAction<HardDropIntent> {
  HardDropAction(BuildContext context)
    : super(context, (provider) => provider.hardDrop());
}

class HoldAction extends _GameAction<HoldIntent> {
  HoldAction(BuildContext context)
    : super(context, (provider) => provider.hold());
}
