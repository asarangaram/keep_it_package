import 'package:flutter/material.dart';

import 'store_actions.dart';

class TheStore extends InheritedWidget {
  const TheStore({
    required this.storeAction,
    required super.child,
    super.key,
  });

  static StoreActions of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TheStore>()!.storeAction;

  /// Represents chat theme.
  final StoreActions storeAction;

  @override
  bool updateShouldNotify(TheStore oldWidget) =>
      storeAction.hashCode != oldWidget.storeAction.hashCode;
}
