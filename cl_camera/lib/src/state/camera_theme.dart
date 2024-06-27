import 'package:flutter/widgets.dart';

import '../models/cl_camera_theme_data.dart';

class DefaultColanThemeColors {}

class CameraTheme extends InheritedWidget {
  const CameraTheme({
    required this.themeData,
    required super.child,
    super.key,
  });

  static CameraTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CameraTheme>()!;

  /// Represents chat theme.
  final CLCameraThemeData themeData;

  @override
  bool updateShouldNotify(CameraTheme oldWidget) =>
      themeData.hashCode != oldWidget.themeData.hashCode;
}
