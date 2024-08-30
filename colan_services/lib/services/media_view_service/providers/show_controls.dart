// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ItemViewModes { fullView, menu }

@immutable
class ShowWhat {
  final ItemViewModes itemViewMode;
  final bool showNotes;
  const ShowWhat({
    this.itemViewMode = ItemViewModes.fullView,
    this.showNotes = false,
  });

  ShowWhat copyWith({
    ItemViewModes? itemViewMode,
    bool? showNotes,
  }) {
    return ShowWhat(
      itemViewMode: itemViewMode ?? this.itemViewMode,
      showNotes: showNotes ?? this.showNotes,
    );
  }

  @override
  String toString() =>
      'ShowWhat(itemViewMode: $itemViewMode, showNotes: $showNotes)';

  @override
  bool operator ==(covariant ShowWhat other) {
    if (identical(this, other)) return true;

    return other.itemViewMode == itemViewMode && other.showNotes == showNotes;
  }

  @override
  int get hashCode => itemViewMode.hashCode ^ showNotes.hashCode;

  bool get showMenu {
    return itemViewMode == ItemViewModes.menu && !showNotes;
  }

  bool get showStatusBar {
    return itemViewMode == ItemViewModes.menu || showNotes;
  }

  bool get showBackground {
    return itemViewMode != ItemViewModes.fullView || showNotes;
  }

  /* bool get showNotes {
    return itemViewMode == ItemViewModes.notes;
  } */
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
      state = state.copyWith(itemViewMode: ItemViewModes.fullView);
    }
  }

  void showControls() {
    if (!state.showMenu) {
      state = state.copyWith(itemViewMode: ItemViewModes.menu);
    }
  }

  void toggleControls() {
    switch (state.itemViewMode) {
      case ItemViewModes.fullView:
        state = state.copyWith(itemViewMode: ItemViewModes.menu);
      case ItemViewModes.menu:
        state = state.copyWith(itemViewMode: ItemViewModes.fullView);
    }
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

  void showNotes() {
    state = state.copyWith(showNotes: true);
  }

  void hideNotes() {
    state = state.copyWith(showNotes: false);
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, ShowWhat>((ref) {
  return ShowControlNotifier();
});
