// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

@immutable
class VideoPlayerState {
  const VideoPlayerState({
    required this.path,
    this.isVisible = false,
    this.paused = true,
    this.controller,
  });
  final String path;
  final bool isVisible;
  final VideoPlayerController? controller;
  final bool paused;

  VideoPlayerState copyWith({
    String? path,
    bool? isVisible,
    VideoPlayerController? controller,
    bool? paused,
  }) {
    return VideoPlayerState(
      path: path ?? this.path,
      isVisible: isVisible ?? this.isVisible,
      paused: paused ?? this.paused,
      controller: controller ?? this.controller,
    );
  }

  @override
  bool operator ==(covariant VideoPlayerState other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.isVisible == isVisible &&
        other.controller == controller &&
        other.paused == paused;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        isVisible.hashCode ^
        controller.hashCode ^
        paused.hashCode;
  }

  @override
  String toString() {
    return 'VideoPlayerState(path: $path, isVisible: $isVisible,'
        ' controller: $controller, paused: $paused)';
  }
}
