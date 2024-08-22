import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../internal/widgets/broken_image.dart';
import '../../internal/widgets/shimmer.dart';
import '../store_service/providers/media_storage.dart';

class ImageViewService extends ConsumerWidget {
  const ImageViewService({
    required this.media,
    super.key,
    this.onLockPage,
  });
  final CLMedia media;

  final void Function({required bool lock})? onLockPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaStorageAsync = ref.watch(mediaStorageProvider(media));

    return mediaStorageAsync.when(
      data: (store) {
        return store.mediaPath.when(
          data: (mediaPath) => ImageViewer.gesture(
            uri: mediaPath,
            initGestureConfigHandler: initGestureConfigHandler,
          ),
          error: BrokenImage.show,
          loading: GreyShimmer.show,
        );
      },
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }

  GestureConfig initGestureConfigHandler(ExtendedImageState state) {
    return GestureConfig(
      inPageView: true,
      animationMaxScale: 10,
      minScale: 1,
      maxScale: 10,
      gestureDetailsIsChanged: (details) {
        if (details?.totalScale == null) return;
        onLockPage?.call(lock: details!.totalScale! > 1.0);
      },
    );
  }
}
