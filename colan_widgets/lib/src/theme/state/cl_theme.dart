import 'package:flutter/widgets.dart';

import '../models/cl_colors.dart';
import '../models/cl_icons.dart';
import '../models/note_theme.dart';

class DefaultColanThemeColors {}

class CLTheme extends InheritedWidget {
  const CLTheme({
    required this.colors,
    required this.noteTheme,
    required this.icons,
    required super.child,
    super.key,
  });

  static CLTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CLTheme>()!;

  /// Represents chat theme.
  final CLColors colors;
  final NotesTheme noteTheme;
  final CLIcons icons;

  @override
  bool updateShouldNotify(CLTheme oldWidget) =>
      colors.hashCode != oldWidget.colors.hashCode;
}
