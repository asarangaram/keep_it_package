import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ItemViewModes { fullView, menu }

@immutable
class ShowWhat {
  const ShowWhat({
    this.isFullScreen = true,
    this.showMenu = true,
  });

  factory ShowWhat.fromMap(Map<String, dynamic> map) {
    return ShowWhat(
      isFullScreen: (map['isFullScreen'] ?? false) as bool,
      showMenu: (map['showMenu'] ?? false) as bool,
    );
  }

  factory ShowWhat.fromJson(String source) =>
      ShowWhat.fromMap(json.decode(source) as Map<String, dynamic>);

  final bool isFullScreen;
  final bool showMenu;

  ShowWhat copyWith({
    bool? isFullScreen,
    bool? showMenu,
  }) {
    return ShowWhat(
      isFullScreen: isFullScreen ?? this.isFullScreen,
      showMenu: showMenu ?? this.showMenu,
    );
  }

  @override
  String toString() =>
      'ShowWhat(isFullScreen: $isFullScreen, showMenu: $showMenu)';

  @override
  bool operator ==(covariant ShowWhat other) {
    if (identical(this, other)) return true;

    return other.isFullScreen == isFullScreen && other.showMenu == showMenu;
  }

  @override
  int get hashCode => isFullScreen.hashCode ^ showMenu.hashCode;

  /* bool get showNotes {
    return itemViewMode == ItemViewModes.notes;
  } */

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isFullScreen': isFullScreen,
      'showMenu': showMenu,
    };
  }

  String toJson() => json.encode(toMap());
}

class ShowControlNotifier extends StateNotifier<ShowWhat> {
  ShowControlNotifier() : super(const ShowWhat()) {
    briefHover(timeout: const Duration(seconds: 5));
  }

  Timer? disableControls;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  void fullScreen() {
    state = state.copyWith(
      isFullScreen: true,
    );
  }

  void fullScreenOff() {
    state = state.copyWith(
      isFullScreen: false,
    );
  }

  void fullScreenToggle() {
    state = state.copyWith(
      isFullScreen: !state.isFullScreen,
    );
  }

  void showControls() {
    state = state.copyWith(
      showMenu: true,
    );
  }

  void hideControls() {
    state = state.copyWith(
      showMenu: false,
    );
  }

  void briefHover({Duration? timeout}) {
    disableControls?.cancel();
    showControls();
    if (timeout != null) {
      disableControls = Timer(
        timeout,
        () {
          if (mounted) {
            hideControls();
          }
        },
      );
    }
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, ShowWhat>((ref) {
  return ShowControlNotifier();
});
