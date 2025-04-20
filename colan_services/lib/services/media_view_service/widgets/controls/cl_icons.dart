import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@immutable
class VideoPlayerIcons {
  final audioMuted = MdiIcons.volumeOff;
  final audioUnmuted = MdiIcons.volumeHigh;
  final playerPause = Icons.pause;
  final playerPlay = Icons.play_arrow;
  final playerStop = Icons.stop;
  final fullscreenExit = MdiIcons.fullscreenExit;
  final fullscreen = MdiIcons.fullscreen;
}

VideoPlayerIcons videoPlayerIcons = VideoPlayerIcons();
