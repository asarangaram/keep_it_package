import 'package:flutter/material.dart';

class QuickMenuStyle {
  final Color barrierColor;
  final Color? foregroundColor;

  final TextStyle? titleStyle;
  final BoxDecoration? backgroundDecoration;
  QuickMenuStyle({
    this.barrierColor = Colors.transparent,
    this.foregroundColor,
    this.backgroundDecoration,
    this.titleStyle,
  });
}
