import 'package:colan_widgets/colan_widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../store_service/widgets/get_media_uri.dart';

class ImageViewService extends StatelessWidget {
  const ImageViewService({
    required this.media,
    super.key,
    this.onLockPage,
  });
  final CLMedia media;

  final void Function({required bool lock})? onLockPage;

  @override
  Widget build(BuildContext context) {
    return GetMediaUri(
      media,
      builder: (uri) => ImageViewer.gesture(
        uri: uri,
        initGestureConfigHandler: initGestureConfigHandler,
      ),
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
