// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

@immutable
class VideoPlayerState {
  final String? path;
  final AsyncValue<VideoPlayerController> controllerAsync;
  const VideoPlayerState({
    this.path,
    this.controllerAsync = const AsyncValue.loading(),
  });

  @override
  bool operator ==(covariant VideoPlayerState other) {
    if (identical(this, other)) return true;

    return other.path == path && other.controllerAsync == controllerAsync;
  }

  @override
  int get hashCode => path.hashCode ^ controllerAsync.hashCode;

  VideoPlayerState copyWith({
    String? path,
    AsyncValue<VideoPlayerController>? controllerAsync,
  }) {
    return VideoPlayerState(
      path: path ?? this.path,
      controllerAsync: controllerAsync ?? this.controllerAsync,
    );
  }
}
