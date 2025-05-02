import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

@immutable
class VideoPlayerState {
  const VideoPlayerState({
    this.path,
    this.controller,
  });
  final Uri? path;
  final VideoPlayerController? controller;

  @override
  bool operator ==(covariant VideoPlayerState other) {
    if (identical(this, other)) return true;

    return other.path == path && other.controller == controller;
  }

  @override
  int get hashCode => path.hashCode ^ controller.hashCode;

  VideoPlayerState copyWith({
    ValueGetter<Uri?>? path,
    VideoPlayerController? controller,
  }) {
    return VideoPlayerState(
      path: path != null ? path.call() : this.path,
      controller: controller ?? this.controller,
    );
  }
}
