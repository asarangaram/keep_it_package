import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ShowWhat {
  const ShowWhat({
    this.showControls = true,
    this.isFullScreen = true,
  });
  final bool showControls;
  final bool isFullScreen;

  ShowWhat copyWith({
    bool? showControls,
    bool? isFullScreen,
  }) {
    return ShowWhat(
      showControls: showControls ?? this.showControls,
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }

  @override
  String toString() =>
      'ShowWhat(showControls: $showControls, isFullScreen: $isFullScreen)';

  @override
  bool operator ==(covariant ShowWhat other) {
    if (identical(this, other)) return true;

    return other.showControls == showControls &&
        other.isFullScreen == isFullScreen;
  }

  @override
  int get hashCode => showControls.hashCode ^ isFullScreen.hashCode;

  bool get showMenu {
    return showControls;
  }

  bool get showStatusBar {
    return showControls;
  }

  bool get showBackground {
    return isFullScreen;
  }
}

class ShowControlNotifier extends StateNotifier<ShowWhat> {
  ShowControlNotifier() : super(const ShowWhat());

  Timer? disableControls;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  void hideControls() {
    if (state.showMenu) {
      state = state.copyWith(showControls: false);
    }
  }

  void showControls() {
    if (!state.showMenu) {
      state = state.copyWith(showControls: true);
    }
  }

  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
  }

  void fullScreenOn() {
    state = state.copyWith(isFullScreen: true);
  }

  void fullScreenOff() {
    state = state.copyWith(isFullScreen: false);
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
