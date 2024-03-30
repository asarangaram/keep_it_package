import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuControl {
  MenuControl({this.menuPosition = const Offset(100, 500)});
  final Offset menuPosition;

  MenuControl copyWith({Offset? menuPosition}) =>
      MenuControl(menuPosition: menuPosition ?? this.menuPosition);
}

class MenuControlNotifier extends StateNotifier<MenuControl> {
  MenuControlNotifier() : super(MenuControl());

  void setMenuPosition(Offset pos) {
    state = state.copyWith(menuPosition: pos);
  }
}

final menuControlNotifierProvider =
    StateNotifierProvider<MenuControlNotifier, MenuControl>((ref) {
  throw Exception('You must  override menuControlNotifierProvider to use');
});
