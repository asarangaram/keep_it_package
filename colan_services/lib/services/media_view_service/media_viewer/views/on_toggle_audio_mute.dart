import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'video_progress.dart';

class OnToggleAudioMute extends StatelessWidget {
  const OnToggleAudioMute({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return MenuBackground(
      child: GetUriPlayStatus(
        uri: uri,
        builder: ([playerControls, playStatus]) {
          if (playerControls == null || playStatus == null) {
            return const SizedBox.shrink();
          }
          return CLButtonIcon.small(
            playStatus.volume == 0
                ? playerUIPreferences.audioMuted
                : playerUIPreferences.audioUnmuted,
            onTap: playerControls.onToggleAudioMute,
            color: playStatus.volume == 0
                ? ShadTheme.of(context).colorScheme.destructive
                : ShadTheme.of(context).colorScheme.background,
          );
        },
      ),
    );
  }
}
/* 
class OnToggleAudioMute2 extends StatelessWidget {
  const OnToggleAudioMute2({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetUriPlayStatus(
      uri: uri,
      builder: ([playerControls, playStatus]) {
        if (playerControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        {
          return CircledIcon(
            playStatus.volume == 0
                ? videoPlayerIcons.audioMuted
                : videoPlayerIcons.audioUnmuted,
            onTap: playerControls.onToggleAudioMute,
            color: playStatus.volume == 0
                ? ShadTheme.of(context).colorScheme.destructive
                : ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
}
 */
