import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';

import 'cl_media.dart';
import 'cl_media_type.dart';

class CLMediaVideo extends CLMedia {
  CLMediaVideo({
    required super.path,
    required super.type,
    super.url,
    super.previewPath,
  }) : super();

  @override
  CLMediaVideo copyWith({
    String? path,
    CLMediaType? type,
    String? url,
    String? previewPath,
  }) {
    return CLMediaVideo(
      path: path ?? this.path,
      type: type ?? this.type,
      url: url ?? this.url,
      previewPath: previewPath ?? this.previewPath,
    );
  }

  @override
  Future<CLMediaVideo> withPreview({
    bool forceCreate = false,
    int width = 64,
  }) async {
    // if previewPath is already set, and not asked to force create,
    if (previewPath != null && !forceCreate) {
      return this;
    }

    final previewFile = File(previewFileName);

    final thumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    if (thumbnail == null) {
      throw Exception('3Unable to create preview for $path');
    }

    previewFile
      ..createSync(recursive: true)
      ..writeAsBytesSync(
        thumbnail.buffer
            .asUint8List(thumbnail.offsetInBytes, thumbnail.lengthInBytes),
      );

    return copyWith(
      previewPath: previewPath ?? '$path.jpg',
    );
  }
}

/* class VideoHandler {
  static Future<Uint8List> createVideoThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 64, // specify the width of the thumbnail, let the height
      // auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return thumbnail!;
  }

  static Future<void> generateVideoThumbnail(String videoPath) async {
    final thumbnailFile = File('$videoPath.tb');
    final thumbnail = await createVideoThumbnail(videoPath);
    await thumbnailFile.writeAsBytes(thumbnail);
  }

  static Future<Uint8List> loadVideoThumbnail(
    String videoPath, {
    bool regenerateIfNotExists = false,
    bool regenerate = false,
  }) async {
    final thumbnailFile = File('$videoPath.tb');
    if (!regenerate) {
      if (thumbnailFile.existsSync()) {
        return thumbnailFile.readAsBytes();
      }
    }
    final thumbnail = await createVideoThumbnail(videoPath);
    if (regenerateIfNotExists || regenerate) {
      await thumbnailFile.writeAsBytes(thumbnail);
    }
    return thumbnail;
  }
}
 */
