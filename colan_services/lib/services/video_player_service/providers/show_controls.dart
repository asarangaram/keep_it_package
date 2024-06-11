// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ShowWhat {
  final bool bottomMenu;
  final bool notes;
  const ShowWhat({
    this.bottomMenu = false,
    this.notes = false,
  });

  ShowWhat copyWith({
    bool? bottomMenu,
    bool? notes,
  }) {
    return ShowWhat(
      bottomMenu: bottomMenu ?? this.bottomMenu,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'ShowWhat(bottomMenu: $bottomMenu, showNotes: $notes)';

  @override
  bool operator ==(covariant ShowWhat other) {
    if (identical(this, other)) return true;

    return other.bottomMenu == bottomMenu && other.notes == notes;
  }

  @override
  int get hashCode => bottomMenu.hashCode ^ notes.hashCode;
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
    if (state.bottomMenu) {
      state = state.copyWith(bottomMenu: false);
    }
  }

  void showControls() {
    if (!state.bottomMenu) {
      state = state.copyWith(bottomMenu: true);
    }
  }

  void toggleControls() {
    state = state.copyWith(bottomMenu: !state.bottomMenu);
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
