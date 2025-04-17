/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract mixin class PageControls {
  void toggleLock();
  void next();
  void prev();
  void goToPage(int index);
}

class PageControllerNotifier extends StateNotifier<PageController>
    with PageControls {
  PageControllerNotifier() : super(PageController());
  bool locked = false;

  @override
  void toggleLock() => locked = !locked;
  @override
  void next() {
    state.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void prev() {
    state.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void goToPage(int index) {
    state.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

final pageControllerProvider = StateNotifierProvider.family<
    PageControllerNotifier,
    PageController,
    ViewIdentifier>((ref, viewIdentifier) {
  return PageControllerNotifier();
});
 */
