// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'video_player_state.dart';

@immutable
class ShowControl {
  final bool isHover;

  final VideoPlayerController? controller;
  const ShowControl({
    required this.isHover,
    this.controller,
  });

  ShowControl copyWith({
    bool? isHover,
    VideoPlayerController? controller,
  }) {
    return ShowControl(
      isHover: isHover ?? this.isHover,
      controller: controller ?? this.controller,
    );
  }

  bool get showControl => isHover || !(controller?.value.isPlaying ?? false);

  @override
  bool operator ==(covariant ShowControl other) {
    if (identical(this, other)) return true;

    return other.isHover == isHover && other.controller == controller;
  }

  @override
  int get hashCode => isHover.hashCode ^ controller.hashCode;

  @override
  String toString() =>
      'ShowControl(isHover: $isHover, controller: $controller)';
}

class ShowControlNotifier extends StateNotifier<ShowControl> {
  ShowControlNotifier({VideoPlayerController? controller})
      : super(
          ShowControl(
            isHover: false,
            controller: controller,
          ),
        ) {
    if (controller != null) {
      controller.addListener(listener);
    }
  }

  Timer? disableControls;

  void listener() {
    if (!mounted) return;
    if (state.controller == null) {
      return;
    }

    state = state.copyWith();
  }

  @override
  void dispose() {
    disableControls?.cancel();
    state.controller?.removeListener(listener);
    super.dispose();
  }

  void onHover() {
    state = state.copyWith(isHover: true);

    disableControls?.cancel();
    disableControls = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          state = state.copyWith(isHover: false);
        }
      },
    );
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, ShowControl>((ref) {
  final state = ref.watch(videoPlayerStateProvider);

  final notifier = state.controllerAsync.when(
    data: (controller) => ShowControlNotifier(controller: controller),
    error: (_, __) => ShowControlNotifier(),
    loading: ShowControlNotifier.new,
  );

  return notifier;
});
