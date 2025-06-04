import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_position.dart';

class MenuPositionNotifier extends StateNotifier<MenuPosition> {
  MenuPositionNotifier() : super(MenuPosition());

  void setMenuPosition(Offset pos) {
    state = state.copyWith(menuPosition: pos);
  }
}

final menuPositionNotifierProvider =
    StateNotifierProvider<MenuPositionNotifier, MenuPosition>((ref) {
  throw Exception('You must  override menuControlNotifierProvider to use');
});
