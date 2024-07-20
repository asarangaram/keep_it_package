import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class TheScreenHandler extends InheritedWidget {
  const TheScreenHandler({
    required this.storeAction,
    required super.child,
    super.key,
  });

  static ScreenHandler of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<TheScreenHandler>()!
      .storeAction;

  /// Represents chat theme.
  final ScreenHandler storeAction;

  @override
  bool updateShouldNotify(TheScreenHandler oldWidget) =>
      storeAction.hashCode != oldWidget.storeAction.hashCode;
}
