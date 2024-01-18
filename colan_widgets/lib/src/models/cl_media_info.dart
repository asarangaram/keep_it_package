/* import 'dart:io';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';

@immutable

class CLMediaVideo extends CLMedia {
  CLMediaVideo({
    required super.path,
    required super.type,
    super.previewPath,
    super.dimension,
    super.previewDim,
  }) : super();

  @override
  CLMediaVideo copyWith({
    String? path,
    CLMediaType? type,
    String? previewPath,
    Size? previewDim,
    Size? dimension,
  }) {
    return CLMediaVideo(
      path: path ?? this.path,
      type: type ?? this.type,
      previewPath: previewPath ?? this.previewPath,
      previewDim: previewDim ?? this.previewDim,
      dimension: dimension ?? this.dimension,
    );
  }

  Future<ui.Image> createThumbnail({
    required int width,
    int? height,
  }) async {
    final previewPath = '$path.tb';
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: width, // specify the width of the thumbnail, let the height
        // auto-scaled to keep the source aspect ratio
        maxHeight: height ?? 0,
        quality: 25,
      );
    } catch (e) {
      // remove thumbnail
      if (preview != null) {
        await File(previewPath).deleteIfExists();
      }
      return CLMediaVideo(path: path, type: type);
    }
  }
}

 */
