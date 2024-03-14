// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class ShowControlNotifier extends StateNotifier<bool> {
  ShowControlNotifier() : super(false);

  Timer? disableControls;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  void hideControls() {
    state = false;
  }

  void showControls() {
    state = true;
  }

  void toggleControls() {
    state = !state;
  }

  void briefHover({Duration? timeout}) {
    disableControls?.cancel();
    state = true;
    if (timeout != null) {
      disableControls = Timer(
        timeout,
        () {
          if (mounted) {
            state = false;
          }
        },
      );
    }
  }
}

final showControlsProvider =
    StateNotifierProvider.autoDispose<ShowControlNotifier, bool>((ref) {
  return ShowControlNotifier();
});
