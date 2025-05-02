import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@immutable
class PlayerUIPreferences {
  final audioMuted = MdiIcons.volumeOff;
  final audioUnmuted = MdiIcons.volumeHigh;
  final playerPause = Icons.pause;
  final playerPlay = Icons.play_arrow;
  final playerStop = Icons.stop;
  final fullscreenExit = MdiIcons.fullscreenExit;
  final fullscreen = MdiIcons.fullscreen;
  final playerClose = MdiIcons.close;

  final foregroundColor = const Color.fromARGB(192, 0xFF, 0xFF, 0xFF);

  final inactiveColor = const Color.fromARGB(192, 64, 64, 64);
  final activeBufferColor = const Color.fromARGB(192, 128, 128, 128);
}

PlayerUIPreferences playerUIPreferences = PlayerUIPreferences();
