import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/cl_media.dart';

class CLMediaPreview extends StatelessWidget {
  const CLMediaPreview({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: switch (media.type) {
              CLMediaType.image => Image.file(
                  File(media.previewPath!),
                  fit: BoxFit.cover,
                ),
              CLMediaType.video => (media.previewPath != null)
                  ? Image.file(
                      File(media.previewPath!),
                      fit: BoxFit.cover,
                    )
                  : FutureBuilder(
                      future: VideoThumbnail.thumbnailData(
                        video: media.path,
                        imageFormat: ImageFormat.JPEG,
                        maxHeight: 128,
                        maxWidth:
                            128, // specify the width of the thumbnail, let
                        /// the height auto-scaled to keep the source aspect ratio
                        quality: 25,
                      ),
                      builder: (context, snapShot) {
                        return snapShot.hasData
                            ? Image.memory(
                                snapShot.data!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: BoxDecoration(border: Border.all()),
                                child: Center(
                                  child: Text(path.basename(media.path)),
                                ),
                              );
                      },
                    ),
              _ => AspectRatio(
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
                              path.basename(media.path),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(media.type.name),
          ),
        ],
      ),
    );
  }
}
