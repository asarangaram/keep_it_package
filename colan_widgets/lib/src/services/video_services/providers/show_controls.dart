// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

@immutable
class ShowControl {
  final bool isHover;

  const ShowControl({
    required this.isHover,
  });

  ShowControl copyWith({
    bool? isHover,
    VideoPlayerController? controller,
  }) {
    return ShowControl(
      isHover: isHover ?? this.isHover,
    );
  }

  bool get showControl => isHover;

  @override
  bool operator ==(covariant ShowControl other) {
    if (identical(this, other)) return true;

    return other.isHover == isHover;
  }

  @override
  int get hashCode => isHover.hashCode;

  @override
  String toString() => 'ShowControl(isHover: $isHover)';
}

class ShowControlNotifier extends StateNotifier<ShowControl> {
  ShowControlNotifier() : super(const ShowControl(isHover: false));

  Timer? disableControls;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  void hideControls() {
    state = state.copyWith(isHover: false);
  }

  void showControls() {
    state = state.copyWith(isHover: false);
  }

  void toggleControls() {
    state = state.copyWith(isHover: !state.isHover);
  }

  void briefHover({Duration? timeout}) {
    disableControls?.cancel();
    state = state.copyWith(isHover: true);
    if (timeout != null) {
      disableControls = Timer(
        timeout,
        () {
          if (mounted) {
            state = state.copyWith(isHover: false);
          }
        },
      );
    }
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, ShowControl>((ref) {
  return ShowControlNotifier();
});
