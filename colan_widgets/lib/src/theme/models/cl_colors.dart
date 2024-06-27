import 'package:flutter/material.dart';

@immutable
class CLColors {
  const CLColors({
    required this.borderColor0,
    required this.iconColor,
    required this.iconColorTransparent,
    required this.disabledIconColor,
    required this.disabledIconColorTransparent,
    required this.iconBackground,
    required this.iconBackgroundTransparent,
    required this.textColor,
    required this.gradientColors1,
    required this.wizardButtonForegroundColor,
    required this.wizardButtonBackgroundColor,
    required this.editorBackgroundColor,
    required this.errorTextForeground,
    required this.errorTextBackground,
  });
  final Color borderColor0;
  final Color iconColor;
  final Color iconColorTransparent;
  final Color disabledIconColor;
  final Color disabledIconColorTransparent;
  final Color iconBackgroundTransparent;
  final Color iconBackground;
  final Color textColor;
  final List<Color> gradientColors1;

  final Color wizardButtonForegroundColor;
  final Color wizardButtonBackgroundColor;
  final Color editorBackgroundColor;

  final Color errorTextForeground;
  final Color errorTextBackground;

  @override
  bool operator ==(covariant CLColors other) {
    if (identical(this, other)) return true;

    return other.borderColor0 == borderColor0;
  }

  @override
  int get hashCode => borderColor0.hashCode;
}

class DefaultCLColors extends CLColors {
  const DefaultCLColors({
    super.borderColor0 = const Color.fromARGB(0xFF, 47, 27, 198),
    super.iconColor = const Color.fromARGB(0xFF, 0, 0, 0),
    super.iconColorTransparent = const Color.fromARGB(192, 0xFF, 0xFF, 0xFF),
    super.disabledIconColor = const Color.fromARGB(0xFF, 192, 192, 192),
    super.disabledIconColorTransparent =
        const Color.fromARGB(192, 192, 192, 192),
    super.iconBackground = const Color.fromARGB(0xFF, 70, 70, 70),
    super.iconBackgroundTransparent = const Color.fromARGB(192, 70, 70, 70),
    super.wizardButtonBackgroundColor = const Color.fromARGB(0xFF, 0, 0, 0),
    super.wizardButtonForegroundColor =
        const Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
    super.editorBackgroundColor = const Color.fromARGB(0xFF, 0, 0, 0),
    super.textColor = const Color.fromARGB(0xFF, 0, 0, 0),
    super.gradientColors1 = const [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ],
    super.errorTextForeground = Colors.red,
    super.errorTextBackground = const Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
  });
}
