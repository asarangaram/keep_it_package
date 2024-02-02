import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/cl_media.dart';

class CLMediaView extends StatelessWidget {
  const CLMediaView({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    if (File(media.path).existsSync()) {
      if (media.previewPath != null || (media.type == CLMediaType.image)) {
        final imageFile = File(media.previewPath ?? media.path);
        if (imageFile.existsSync()) {
          return AspectRatio(
            aspectRatio: 1,
            child: Image.file(
              imageFile,
              fit: !keepAspectRatio ? BoxFit.cover : null,
            ),
          );
        }
      } else if (media.type == CLMediaType.video) {
        return FutureBuilder(
          future: VideoThumbnail.thumbnailData(
            video: media.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth:
                128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
            quality: 25,
          ),
          builder: (context, snapShot) {
            print('Building for Video ${snapShot.connectionState}');
            if (snapShot.hasData) {
              print('datalength= ${snapShot.data!.length}');
            }
            return AspectRatio(
              aspectRatio: 1,
              child: snapShot.hasData
                  ? Image.memory(
                      snapShot.data!,
                      fit: !keepAspectRatio ? BoxFit.cover : null,
                    )
                  : Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Center(
                        child: Text(media.path),
                      ),
                    ),
            );
          },
        );
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 60 + 16,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  'Preview Not Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
