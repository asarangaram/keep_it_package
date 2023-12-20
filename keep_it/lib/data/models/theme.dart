import 'package:flutter/material.dart';

class ColorTheme {
  final Color textColor;
  final Color backgroundColor;
  final Color disabledColor;
  final Color overlayBackgroundColor;
  final Color errorColor;
  final Color selectedColor;
  final Color buttonText;
  ColorTheme({
    required this.textColor,
    required this.backgroundColor,
    required this.disabledColor,
    required this.overlayBackgroundColor,
    required this.errorColor,
    required this.selectedColor,
    required this.buttonText,
  });
}

class KeepItTheme {
  ColorTheme colorTheme;
  KeepItTheme({required this.colorTheme});
}
