import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../image_view_service/image_view.dart';
import '../../store_service/providers/media_storage.dart';
import 'image_thumbnail.dart';

class PreviewService extends ConsumerWidget {
  const PreviewService({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaStorageAsync = ref.watch(mediaStorageProvider(media));
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: mediaStorageAsync.when(
        data: (store) {
          return store.previewPath.when(
            data: (previewPath) => previewPath.scheme == 'file'
                ? ImageViewerFile(
                    media,
                    filePath: previewPath.path,
                    fit: fit,
                  )
                : Center(
                    child: Text(previewPath.path),
                  ),
            error: error,
            loading: loading,
          );
        },
        error: error,
        loading: loading,
      ),
    );
  }

  Widget loading() => const Center(child: CircularProgressIndicator());
  Widget error(Object e, StackTrace st) => const BrokenImage();
}

class ImageViewerFile extends ConsumerWidget {
  const ImageViewerFile(
    this.media, {
    required this.filePath,
    super.key,
    this.fit,
  });
  final String filePath;
  final CLMedia media;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: AlbumManager.isPinBroken(media.pin),
      builder: (context, snapshot) {
        return ImageViewerBasic(
          file: File(filePath),
          fit: fit,
          isPinned: media.pin != null,
          isPinBroken: snapshot.data ?? false,
          overlayIcon:
              (media.type == CLMediaType.video) ? Icons.play_arrow_sharp : null,
        );
      },
    );
  }
}

class PreviewServiceOld extends StatelessWidget {
  const PreviewServiceOld({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (media.type.isFile &&
        !File(TheStore.of(context).getMediaPath(media)).existsSync()) {
      //throw Exception('File not found ${media.path}');
      return const BrokenImage();
    }
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;

    return KeepAspectRatio(
      keepAspectRatio: keepAspectRatio,
      child: switch (media.type) {
        CLMediaType.image || CLMediaType.video => ImageThumbnail(
            media: media,
            builder: (context, thumbnailFile) {
              return thumbnailFile.when(
                data: (file) => FutureBuilder(
                  future: AlbumManager.isPinBroken(media.pin),
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
                loading: () => const GreyShadowShimmerContainer(),
              );
            },
          ),
        _ => const BrokenImage()
      },
    );
  }
}

class GreyShadowShimmerContainer extends StatelessWidget {
  const GreyShadowShimmerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Shimmering',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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
