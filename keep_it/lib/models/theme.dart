import 'package:flutter/material.dart';

class ColorTheme {
  final Color textColor;
  final Color backgroundColor;
  final Color disabledColor;
  final Color overlayBackgroundColor;
  final Color errorColor;
  ColorTheme({
    required this.textColor,
    required this.backgroundColor,
    required this.disabledColor,
    required this.overlayBackgroundColor,
    required this.errorColor,
  });
}

class KeepItTheme {
  ColorTheme colorTheme;
  KeepItTheme({required this.colorTheme});
}
