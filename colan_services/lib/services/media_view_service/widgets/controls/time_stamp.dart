import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension ExtDuration on Duration {
  String get timestamp {
    final hh = inHours > 0 ? "${inHours.toString().padLeft(2, '0')}:" : '';
    return '$hh'
        "${inMinutes.toString().padLeft(2, '0')}:"
        "${(inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

class ShowTimeStamp extends ConsumerWidget {
  const ShowTimeStamp({required this.uri, super.key});
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

            String timeStamp(double? seekValue) {
              final isLive =
                  durationToDouble(videoplayerStatus.duration) > 10 * 60 * 60;
              final currentPosition = seekValue == null
                  ? videoplayerStatus.position
                  : doubleToDuration(seekValue);

              if (isLive) {
                if (videoplayerStatus.isCompleted) {
                  return '__ / __';
                }
                return '${currentPosition.timestamp} / __';
              } else {
                return '${currentPosition.timestamp} / ${videoplayerStatus.duration.timestamp}';
              }
            }

            return ShadButton.ghost(
              child: Text(
                timeStamp(null),
              ),
            );
          },
        );
      },
    );
  }
}
