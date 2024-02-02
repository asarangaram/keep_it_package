import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/url_handler.dart';
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
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
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
                            128, // specify the width of the thumbnail, let the
                        ///  height auto-scaled to keep the source aspect ratio
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
              CLMediaType.url => FutureBuilder(
                  future: URLHandler.getMimeType(media.path),
                  builder: (context, snapShot) {
                    if (snapShot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return switch (snapShot.data) {
                      (final mimeType) when mimeType == CLMediaType.image =>
                        Image.network(
                          media.path,
                          fit: BoxFit.cover,
                        ),
                      (final mimeType) when mimeType == CLMediaType.video =>
                        FutureBuilder(
                          future: VideoThumbnail.thumbnailData(
                            video: media.path,
                            imageFormat: ImageFormat.JPEG,
                            maxHeight: 128,
                            maxWidth:
                                128, 
                            quality: 25,
                          ),
                          builder: (context, snapShot) {
                            if (snapShot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return snapShot.hasData
                                ? Image.memory(
                                    snapShot.data!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Center(
                                      child: Text(path.basename(media.path)),
                                    ),
                                  );
                          },
                        ),
                      _ => MediaPlaceHolder(media: media)
                    };
                  },
                ),
              _ => MediaPlaceHolder(media: media)
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

class MediaPlaceHolder extends StatelessWidget {
  const MediaPlaceHolder({
    required this.media,
    super.key,
  });

  final CLMedia media;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
