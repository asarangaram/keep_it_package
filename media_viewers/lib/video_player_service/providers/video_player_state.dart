import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_state.dart';

class VideoPlayerStateNotifier extends StateNotifier<VideoPlayerState> {
  VideoPlayerStateNotifier() : super(const VideoPlayerState());
  VideoPlayerController? controller;

  Future<void> setVideo(Uri uri, {bool autoPlay = true}) async {
    if (state.path == uri) return;
    state = VideoPlayerState(path: uri);
    try {
      if (controller != null) {
        await controller!.pause();
        await controller!.dispose();
      }
      final VideoPlayerController newController;
      if (uri.scheme == 'file') {
        final path = uri.toFilePath();
        if (!File(path).existsSync()) {
          throw FileSystemException('missing file', path);
        }

        controller = VideoPlayerController.file(File(path));
        if (controller == null) {
          throw Exception('Failed to create controller');
        }
        newController = controller!;
        await newController.initialize();
        if (!newController.value.isInitialized) {
          throw Exception('Failed to load Video');
        }

        await newController.seekTo(Duration.zero);
        if (autoPlay) {
          await newController.play();
        }
      } else if (['http', 'https'].contains(uri.scheme)) {
        controller = VideoPlayerController.networkUrl(
          uri,
          formatHint: VideoFormat.hls,
          videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
        );
        if (controller == null) {
          throw Exception('Failed to create controller');
        }
        newController = controller!;
        await newController.initialize();
        if (!newController.value.isInitialized) {
          throw Exception('Failed to load Video');
        }
        // dont autoplay network videos |
        /* await newController.seekTo(Duration.zero);
        if (autoPlay) {
           await newController.play();
        } */
      } else {
        throw Exception('not supported');
      }
      print(newController.value);

      state = state.copyWith(controllerAsync: AsyncValue.data(newController));
    } catch (error, stackTrace) {
      state = state.copyWith(controllerAsync: AsyncError(error, stackTrace));
    }
  }

  Future<void> stopVideo(Uri? path) async {
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
final videoPlayerStateProvider = StateNotifierProvider.autoDispose<
    VideoPlayerStateNotifier, VideoPlayerState>((ref) {
  final notifier = VideoPlayerStateNotifier();
  return notifier;
});
