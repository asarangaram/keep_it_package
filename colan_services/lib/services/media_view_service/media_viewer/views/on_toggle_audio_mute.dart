import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../notifier/riverpod/builders/get_uri_play_status.dart';

class OnToggleAudioMute extends StatelessWidget {
  const OnToggleAudioMute({
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
        return ShadButton.ghost(
          onPressed: playerControls.onToggleAudioMute,
          child: SvgIcon(
            playStatus.volume == 0 ? SvgIcons.audioOff : SvgIcons.audioOn,
            color: playStatus.volume == 0
                ? ShadTheme.of(context).colorScheme.destructive
                : ShadTheme.of(context).colorScheme.background,
            size: 20,
          ),
        );
      },
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
