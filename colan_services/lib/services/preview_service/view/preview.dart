import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../../internal/widgets/shimmer.dart';
import '../../store_service/providers/media_storage.dart';
import 'image_view.dart';

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
    final child = mediaStorageAsync.when(
      data: (store) {
        return store.previewPath.when(
          data: (previewPath) => FutureBuilder(
            future: AlbumManager.isPinBroken(media.pin),
            builder: (context, snapshot) {
              return ImageViewerIconView(
                uri: previewPath,
                fit: fit,
                isPinned: media.pin != null,
                isPinBroken: snapshot.data ?? false,
                overlayIcon: (media.type == CLMediaType.video)
                    ? Icons.play_arrow_sharp
                    : null,
              );
            },
          ),
          error: BrokenImage.show,
          loading: GreyShimmer.show,
        );
      },
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
    if (!keepAspectRatio) return child;
    return AspectRatio(
      aspectRatio: 1,
      child: child,
    );
  }
}
