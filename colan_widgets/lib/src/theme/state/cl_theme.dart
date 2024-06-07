import 'package:flutter/widgets.dart';

import '../models/cl_colors.dart';

class DefaultColanThemeColors {}

class CLTheme extends InheritedWidget {
  const CLTheme({
    required this.colors,
    required super.child,
    super.key,
  });

  static CLTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CLTheme>()!;

  /// Represents chat theme.
  final CLColors colors;

  @override
  bool updateShouldNotify(CLTheme oldWidget) =>
      colors.hashCode != oldWidget.colors.hashCode;
}
