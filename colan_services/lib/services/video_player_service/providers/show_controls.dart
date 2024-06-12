// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ItemViewModes { fullView, menu, notes }

@immutable
class ShowWhat {
  final ItemViewModes itemViewMode;
  const ShowWhat({
    this.itemViewMode = ItemViewModes.fullView,
  });

  ShowWhat copyWith({
    ItemViewModes? itemViewMode,
  }) {
    return ShowWhat(
      itemViewMode: itemViewMode ?? this.itemViewMode,
    );
  }

  @override
  String toString() => 'ShowWhat(itemViewMode: $itemViewMode)';

  @override
  bool operator ==(covariant ShowWhat other) {
    if (identical(this, other)) return true;

    return other.itemViewMode == itemViewMode;
  }

  @override
  int get hashCode => itemViewMode.hashCode;

  bool get showMenu {
    return itemViewMode == ItemViewModes.menu;
  }

  bool get showStatusBar {
    return itemViewMode == ItemViewModes.menu;
  }

  bool get showBackground {
    return itemViewMode != ItemViewModes.fullView;
  }

  bool get showNotes {
    return itemViewMode == ItemViewModes.notes;
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
      case ItemViewModes.notes:
        break;
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
    state = state.copyWith(itemViewMode: ItemViewModes.notes);
  }

  void hideNotes() {
    state = state.copyWith(itemViewMode: ItemViewModes.fullView);
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, ShowWhat>((ref) {
  return ShowControlNotifier();
});
