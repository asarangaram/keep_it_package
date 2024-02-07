import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_state.dart';

final videoPlayerStateProvider = StateNotifierProvider.family.autoDispose<
    VideoPlayerStateNotifier,
    AsyncValue<VideoPlayerState>,
    String>((ref, path) {
  return VideoPlayerStateNotifier(VideoPlayerState(path: path));
});

class VideoPlayerStateNotifier
    extends StateNotifier<AsyncValue<VideoPlayerState>> {
  VideoPlayerStateNotifier(this.initState) : super(const AsyncValue.loading()) {
    create();
  }
  final VideoPlayerState initState;
  VideoPlayerState? lastKnownState;

  @override
  void dispose() {
    lastKnownState?.controller
      ?..removeListener(listener)
      ..dispose();

    super.dispose();
  }

  void listener() {
    //  print(lastKnownState!.controller!.value.isPlaying);
  }

  Future<void> create() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (initState.controller == null) {
        lastKnownState = initState.copyWith(
          controller: VideoPlayerController.file(
            File(initState.path),
          ),
        );
      } else {
        lastKnownState = initState;
      }
      if (!isready()) {
        await lastKnownState!.controller!.initialize();
        await lastKnownState!.controller!.pause();
        lastKnownState!.controller!.addListener(listener);
      }
      if (!(lastKnownState!.controller?.value.isInitialized ?? true)) {
        throw Exception('Failed to initialize Video player');
      }

      return lastKnownState!;
    });
  }

  bool isready() => lastKnownState?.controller?.value.isInitialized ?? false;

  Future<void> guard(
    Future<VideoPlayerState> Function(VideoPlayerState oldState) coreFn,
  ) async {
    state = const AsyncValue.loading();
    if (isready()) {
      state = await AsyncValue.guard(() async {
        lastKnownState = await coreFn(lastKnownState!);
        return lastKnownState!;
      });
    }
  }

  Future<VideoPlayerState> _inactive(VideoPlayerState oldState) async {
    VideoPlayerState? newState;
    if (oldState.isVisible) {
      newState = oldState.copyWith(isVisible: false);
    }

    await oldState.controller!.pause();

    return newState ?? oldState;
  }

  Future<VideoPlayerState> _active(VideoPlayerState oldState) async {
    VideoPlayerState? newState;
    if (!oldState.isVisible) {
      newState = oldState.copyWith(isVisible: true);
    }
    if (!oldState.controller!.value.isPlaying && !oldState.paused) {
      await oldState.controller!.play();
    }
    return newState ?? oldState;
  }

  Future<VideoPlayerState> _pause(VideoPlayerState oldState) async {
    VideoPlayerState? newState;
    if (!oldState.paused) {
      newState = oldState.copyWith(paused: true);
    }

    await oldState.controller!.pause();

    return newState ?? oldState;
  }

  Future<VideoPlayerState> _play(VideoPlayerState oldState) async {
    VideoPlayerState? newState;
    if (oldState.paused) {
      newState = oldState.copyWith(paused: false);
    }
    if (!oldState.controller!.value.isPlaying && oldState.isVisible) {
      await oldState.controller!.play();
    }
    return newState ?? oldState;
  }

  Future<void> inactive() async => guard(_inactive);
  Future<void> active() async => guard(_active);
  Future<void> play() async => guard(_play);
  Future<void> pause() async => guard(_pause);
}
