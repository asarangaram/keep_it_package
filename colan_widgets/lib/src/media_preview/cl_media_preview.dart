import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../basics/cl_icon.dart';
import '../builders/video_preview_builder.dart';
import '../models/cl_media.dart';
import '../models/cl_media/extensions/url_handler.dart';
import '../thumbnail_service/image_thumbnail.dart';
import 'image_preview.dart';
import 'image_view.dart';
import 'missing_preview.dart';

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
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: switch (media.type) {
        CLMediaType.image || CLMediaType.video => ImageThumbnail(
            media: media,
            builder: (context, thumbnailFile) {
              if (thumbnailFile.hasValue) {
                print('Thumbnail Ready for ${thumbnailFile.value?.path}');
              }
              return thumbnailFile.when(
                data: (file) => ImageView(
                  file: file,
                  fit: fit,
                  overlayIcon: (media.type == CLMediaType.video)
                      ? Icons.play_arrow_sharp
                      : null,
                ),
                error: (_, __) => const BrokenImage(),
                loading: () => const Center(child: CircularProgressIndicator()),
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
                    fit: fit,
                  ),
                (final mimeType) when mimeType == CLMediaType.video =>
                  VideoPreviewBuilder(
                    videoPath: media.path,
                    builder: (context, path) {
                      return path.when(
                        data: (path) => UnCachedImagePreview(
                          previewImagePath: path,
                          fit: fit,
                          overlayIcon: Icons.play_arrow_sharp,
                        ),
                        error: (_, __) => CLIcon.large(
                          Icons.broken_image_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        loading: CircularProgressIndicator.new,
                      );
                    },
                  ),
                _ => const MissingPreview()
              };
            },
          ),
        _ => const MissingPreview()
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
