import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/controls/cl_icons.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnTogglePlay extends StatelessWidget {
  const OnTogglePlay({
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
          return CLButtonIcon.standard(
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
}

class OnTogglePlay2 extends StatelessWidget {
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
}
