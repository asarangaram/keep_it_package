import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_state.dart';

class VideoPlayerStateNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerStateNotifier() : super(const VideoPlayerState());
  VideoPlayerController? controller;

  Future<void> playVideo(String path) async {
    if (state.path == path) return;
    state = VideoPlayerState(path: path);
    try {
      if (!File(path).existsSync()) {
        throw FileSystemException('missing file', path);
      }
      if (controller != null) {
        await controller!.pause();
        await controller!.dispose();
      }
      controller = VideoPlayerController.file(File(path));
      if (controller == null) {
        throw Exception('Failed to create controller');
      }
      final newController = controller!;
      await newController.initialize();
      if (!newController.value.isInitialized) {
        throw Exception('Failed to load Video');
      }
      await newController.seekTo(Duration.zero);
      await newController.play();
      state = state.copyWith(controllerAsync: AsyncValue.data(newController));
    } catch (error, stackTrace) {
      state = state.copyWith(controllerAsync: AsyncError(error, stackTrace));
    }
  }

  Future<void> stopVideo(String? path) async {
    if (path == state.path || path == null) {
      if (controller != null) {
        await controller!.pause();
        state = const VideoPlayerState();
        await controller!.dispose();
        controller = null;
      }
    }
  }

  @override
  void dispose() {
    if (mounted) {
      if (controller?.value.isPlaying ?? false) {
        controller?.pause();
      }
      controller?.dispose();
      super.dispose();
    }
  }
}

// Remember: removed .autoDispose
final videoPlayerStateProvider =
    StateNotifierProvider<VideoPlayerStateNotifier, VideoPlayerState>((ref) {
  final notifier = VideoPlayerStateNotifier();
  return notifier;
});


