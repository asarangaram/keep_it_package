import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'video_progress.dart' show MenuBackground;

class OnTogglePlay extends StatelessWidget {
  const OnTogglePlay({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MenuBackground(
        child: GetUriPlayStatus(
          uri: uri,
          builder: ([playerControls, playStatus]) {
            final isPlaying = playStatus?.isPlaying ?? false;

            return CLButtonIcon.standard(
              isPlaying
                  ? playerUIPreferences.playerPause
                  : playerUIPreferences.playerPlay,
              onTap: () => {
                playerControls?.onPlayPause(
                  uri,
                  autoPlay: false,
                  forced: true,
                ),
              },
              color: ShadTheme.of(context).colorScheme.background,
            );
          },
        ),
      ),
    );
  }
}

/* class OnTogglePlay2 extends StatelessWidget {
  const OnTogglePlay2({
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
            playStatus.isPlaying
                ? videoPlayerIcons.playerPause
                : videoPlayerIcons.playerPlay,
            onTap: () => {
              playerControls.onPlayPause(
                autoPlay: false,
                forced: true,
              ),
            },
            color: ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
} */
