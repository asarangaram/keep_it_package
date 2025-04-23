import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_view_state.dart';

class MediaViewerStateNotifier extends StateNotifier<MediaViewerState> {
  MediaViewerStateNotifier(super.state) : super();

  set currIndex(int value) => state = state.copyWith(currentIndex: value);
  int get currIndex => state.currentIndex;

  set lockScreen(bool value) => state = state.copyWith(lockScreen: value);
  bool get lockScreen => state.lockScreen;

  void prevPage(PageController pageController) {
    if (state.currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.animateToPage(
        state.entities.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextPage(PageController pageController) {
    {
      if (state.currentIndex < state.entities.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

final mediaViewerStateProvider =
    StateNotifierProvider<MediaViewerStateNotifier, MediaViewerState>((ref) {
  return throw Exception('Override mising');
});
