import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../image_view_service/image_view.dart';
import 'image_thumbnail.dart';

class PreviewService extends StatelessWidget {
  const PreviewService({
    required this.media,
    required this.getPreviewPath,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  final String Function(CLMedia media) getPreviewPath;
  // TODO(anandas): :  How to make this reactive??
  Future<bool> isPinBroken() async {
    if (media.pin != null) {
      final asset = await AssetEntity.fromId(media.pin!);
      return asset == null;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (media.type.isFile && !File(media.path).existsSync()) {
      //throw Exception('File not found ${media.path}');
      return const BrokenImage();
    }
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;

    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: switch (media.type) {
        CLMediaType.image || CLMediaType.video => ImageThumbnail(
            media: media,
            getPreviewPath: getPreviewPath,
            builder: (context, thumbnailFile) {
              return thumbnailFile.when(
                data: (file) => FutureBuilder(
                  future: isPinBroken(),
                  builder: (context, snapshot) {
                    return ImageViewerBasic(
                      file: file,
                      fit: fit,
                      isPinned: media.pin != null,
                      isPinBroken: snapshot.data ?? false,
                      overlayIcon: (media.type == CLMediaType.video)
                          ? Icons.play_arrow_sharp
                          : null,
                    );
                  },
                ),
                error: (_, __) => const BrokenImage(),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        _ => const BrokenImage()
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
