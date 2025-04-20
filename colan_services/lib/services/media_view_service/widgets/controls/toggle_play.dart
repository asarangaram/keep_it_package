import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'cl_icons.dart';

class OnToggleVideoPlay extends ConsumerWidget {
  const OnToggleVideoPlay({required this.uri, super.key});
  final Uri uri;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetUniversalVideoControls(
      builder: (universalvideoControls) {
        return GetUriPlayStatus(
          uri: uri,
          builder: (uriPlayController, videoplayerStatus) {
            if (videoplayerStatus == null || uriPlayController == null) {
              return const SizedBox.shrink();
            }

            return ShadButton.ghost(
              padding: EdgeInsets.zero,
              icon: Icon(
                videoplayerStatus.isPlaying
                    ? videoPlayerIcons.playerPause
                    : videoPlayerIcons.playerPlay,
              ),
              onPressed: uriPlayController.onPlayPause,
            );
          },
        );
      },
    );
  }
}
