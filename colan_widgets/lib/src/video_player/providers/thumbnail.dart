import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../models/cl_media.dart';

final thumbnailProvider =
    FutureProvider.family<File, CLMedia>((ref, media) async {
  {
    if (!File(media.path).existsSync()) {
      throw FileSystemException('missing', media.path);
    }
    if (media.previewPath != null) {
      final preview = File(media.previewPath!);
      if (preview.existsSync()) {
        return preview;
      }
    }
    {
      final preview = File(media.previewFileName);
      if (preview.existsSync()) {
        return preview;
      }
    }
  }
  // Now its clearn we don't have preview already generated.
  // Lets try generating. For now, we support only Video thumbnail
  if (media.type != CLMediaType.video) {
    throw Exception('thumbnail not found');
  }

  final thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: media.path,
    imageFormat: ImageFormat.JPEG,
    quality: 25,
  );
  if (thumbnailPath == null) {
    throw Exception('Unable to generate thumbnail');
  }
  return File(thumbnailPath);
});
