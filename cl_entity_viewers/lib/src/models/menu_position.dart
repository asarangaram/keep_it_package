import 'package:flutter/material.dart';

class MenuPosition {
  MenuPosition({this.menuPosition = const Offset(100, 500)});
  final Offset menuPosition;

  MenuPosition copyWith({Offset? menuPosition}) =>
      MenuPosition(menuPosition: menuPosition ?? this.menuPosition);
}
