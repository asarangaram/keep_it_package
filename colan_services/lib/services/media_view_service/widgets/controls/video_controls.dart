import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/controls/cl_icons.dart';
import 'package:colan_services/services/media_view_service/widgets/controls/toggle_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

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
          child: ShadButton.ghost(
            padding: EdgeInsets.zero,
            icon: Icon(
              playStatus.isPlaying
                  ? videoPlayerIcons.playerPause
                  : videoPlayerIcons.playerPlay,
            ),
            onPressed: () => playerControls.onPlayPause(
              autoPlay: false,
              forced: true,
            ),
          ),
        ),
        FittedBox(
          child: ShadButton.ghost(
            icon: Icon(
              playStatus.volume == 0
                  ? videoPlayerIcons.audioMuted
                  : videoPlayerIcons.audioUnmuted,
            ),
            onPressed: playerControls.onToggleAudioMute,
          ),
        ),
        const Spacer(),
        const FittedBox(child: OnToggleFullScreen()),
      ],
    );
  }
}
