import 'package:flutter/material.dart';

@immutable
class CLColors {
  const CLColors({
    required this.borderColor0,
    required this.iconColor,
    required this.iconColorTransparent,
    required this.disabledIconColor,
    required this.disabledIconColorTransparent,
    required this.textColor,
    required this.gradientColors1,
  });
  final Color borderColor0;
  final Color iconColor;
  final Color iconColorTransparent;
  final Color disabledIconColor;
  final Color disabledIconColorTransparent;
  final Color textColor;
  final List<Color> gradientColors1;

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
    super.borderColor0 = const Color.fromARGB(255, 47, 27, 198),
    super.iconColor = const Color.fromARGB(255, 0, 0, 0),
    super.iconColorTransparent = const Color.fromARGB(192, 0, 0, 0),
    super.disabledIconColor = const Color.fromARGB(255, 70, 70, 70),
    super.disabledIconColorTransparent = const Color.fromARGB(192, 70, 70, 70),
    super.textColor = const Color.fromARGB(255, 0, 0, 0),
    super.gradientColors1 = const [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ],
  });
}
