import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'cl_icons.dart';

class OnToggleAudioMute extends ConsumerWidget {
  const OnToggleAudioMute({required this.uri, super.key});
  final Uri uri;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetUniversalVideoControls(
      builder: (universalvideoControls) {
        return GetUriPlayStatus(
          uri: uri,
          builder: (videoplayerStatus) {
            if (videoplayerStatus == null) {
              return const SizedBox.shrink();
            }

            return ShadButton.ghost(
              icon: Icon(
                videoplayerStatus.volume == 0
                    ? videoPlayerIcons.audioMuted
                    : videoPlayerIcons.audioUnmuted,
              ),
              onPressed: universalvideoControls.onToggleAudioMute,
            );
          },
        );
      },
    );
  }
}
