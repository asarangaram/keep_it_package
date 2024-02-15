import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPreviewBuilder extends StatelessWidget {
  const VideoPreviewBuilder({
    required this.videoPath,
    required this.builder,
    super.key,
    this.thumbnailPath,
    this.refresh = false,
  });

  final String videoPath;
  final String? thumbnailPath;
  final Widget Function(BuildContext context, AsyncValue<String> path) builder;
  final bool refresh;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: () async {
        if (thumbnailPath != null &&
            File(thumbnailPath!).existsSync() &&
            !refresh) {
          return thumbnailPath!;
        }
        final preview = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: thumbnailPath,
          maxWidth: 256,
          imageFormat: ImageFormat.JPEG,
        );
        if (preview == null) {
          throw Exception('Failed to generate video preview');
        }
        return thumbnailPath!;
      }(),
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return builder(context, const AsyncValue.loading());
        }
        if (snapShot.hasError) {
          return builder(
            context,
            AsyncError<String>(snapShot.error!, snapShot.stackTrace!),
          );
        } else {
          try {
            if (snapShot.hasData) {
              return builder(context, AsyncData<String>(snapShot.data!));
            }
            throw Exception('Unexpected: hasData == false');
          } catch (error, stackTrace) {
            return builder(context, AsyncError<String>(error, stackTrace));
          }
        }
      },
    );
  }
}
