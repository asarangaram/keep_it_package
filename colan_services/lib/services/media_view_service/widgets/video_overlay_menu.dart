import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/services/media_view_service/widgets/controls/video_controls.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'controls/video_progress.dart';

class VideoOverlayMenu extends StatelessWidget {
  const VideoOverlayMenu({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetUriPlayStatus(
      uri: uri,
      builder: ([playControls, playStatus]) {
        if (playControls == null || playStatus == null) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.black54,
              width: constraints.maxWidth, // Matches media width
              child: ShadTheme(
                data: ShadTheme.of(context).copyWith(
                  textTheme: ShadTheme.of(context).textTheme.copyWith(
                        small: ShadTheme.of(context).textTheme.small.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                      ),
                  ghostButtonTheme: const ShadButtonTheme(
                    foregroundColor: Colors.white,
                    size: ShadButtonSize.sm,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VideoProgress(
                      playerControls: playControls,
                      playStatus: playStatus,
                    ),
                    VideoControls(
                      playerControls: playControls,
                      playStatus: playStatus,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
