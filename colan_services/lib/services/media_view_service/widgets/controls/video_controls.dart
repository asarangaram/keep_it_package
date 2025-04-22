import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/controls/cl_icons.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'menu_icon_decorator.dart';

class VideoControls extends StatelessWidget {
  const VideoControls({
    required this.playerControls,
    required this.playStatus,
    super.key,
  });

  final VideoPlayerControls playerControls;
  final VideoPlayerValue playStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FittedBox(
          child: MenuItemView(
            CLMenuItem(
              title: playStatus.isPlaying ? 'Pause' : 'Play',
              icon: playStatus.isPlaying
                  ? videoPlayerIcons.playerPause
                  : videoPlayerIcons.playerPlay,
              onTap: () async {
                await playerControls.onPlayPause(
                  autoPlay: false,
                  forced: true,
                );

                return true;
              },
            ),
          ),
        ),
        FittedBox(
          child: MenuItemView(
            CLMenuItem(
              title: 'Audio Mute',
              icon: playStatus.volume == 0
                  ? videoPlayerIcons.audioMuted
                  : videoPlayerIcons.audioUnmuted,
              onTap: () async {
                await playerControls.onToggleAudioMute();
                return true;
              },
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
