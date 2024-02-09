import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/url_handler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../basics/cl_icon.dart';
import '../models/cl_media.dart';

class CLMediaPreview extends StatelessWidget {
  const CLMediaPreview({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
    this.videoOverlayChild,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  final Widget? videoOverlayChild;
  @override
  Widget build(BuildContext context) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      throw Exception('File not found ${media.path}');
    }
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: switch (media.type) {
        CLMediaType.image => Image.file(
            File(media.previewPath!),
            fit: fit,
          ),
        CLMediaType
              .video => /* (media.previewPath != null)
            ? Image.file(
                File(media.previewPath!),
                fit: fit,
              )
            :  */
          VideoPreview(
            media: media,
            videoOverlayChild: videoOverlayChild,
            keepAspectRatio: keepAspectRatio,
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
                    fit: fit,
                  ),
                (final mimeType) when mimeType == CLMediaType.video =>
                  VideoPreview(
                    media: media,
                    videoOverlayChild: videoOverlayChild,
                  ),
                _ => MediaPlaceHolder(media: media)
              };
            },
          ),
        _ => MediaPlaceHolder(media: media)
      },
    );
  }
}

class VideoPreview extends StatelessWidget {
  const VideoPreview({
    required this.media,
    this.videoOverlayChild,
    super.key,
    this.keepAspectRatio = true,
  });

  final CLMedia media;
  final Widget? videoOverlayChild;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    return FutureBuilder(
      future: VideoThumbnail.thumbnailData(
        video: media.path,
      ),
      builder: (context, snapShot) {
        return snapShot.hasData
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Image.memory(
                      snapShot.data!,
                      fit: fit,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.2,
                        heightFactor: 0.2,
                        child: FittedBox(
                          child: videoOverlayChild ?? const VidoePlayIcon(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Center(
                  child: Text(path.basename(media.path)),
                ),
              );
      },
    );
  }
}

class KeepAspectRatio extends StatelessWidget {
  const KeepAspectRatio({
    required this.child,
    super.key,
    this.keepAspectRatio = true,
    this.aspectRatio,
  });
  final bool keepAspectRatio;
  final Widget child;
  final double? aspectRatio;
  @override
  Widget build(BuildContext context) {
    if (keepAspectRatio) return child;
    return AspectRatio(
      aspectRatio: aspectRatio ?? 1,
      child: child,
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

class VidoePlayIcon extends StatelessWidget {
  const VidoePlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      child: CLIcon.veryLarge(
        Icons.play_arrow_sharp,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
      ),
    );
  }
}
