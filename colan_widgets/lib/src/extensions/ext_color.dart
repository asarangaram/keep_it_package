import 'package:flutter/material.dart';

extension ExtColor on Color {
  Color invertColor() {
    return Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
  }

  Color reduceBrightness(double factor) {
    assert(
      factor >= 0.0 && factor <= 1.0,
      'Factor should be between 0.0 and 1.0',
    );

    final hslColor = HSLColor.fromColor(this);
    final newLightness = (hslColor.lightness - factor).clamp(0.0, 1.0);

    return hslColor.withLightness(newLightness).toColor();
  }

  Color increaseBrightness(double factor) {
    assert(
      factor >= 0.0 && factor <= 1.0,
      'Factor should be between 0.0 and 1.0',
    );

    final hslColor = HSLColor.fromColor(this);
    final newLightness = (hslColor.lightness + factor).clamp(0.0, 1.0);

    return hslColor.withLightness(newLightness).toColor();
  }
}
