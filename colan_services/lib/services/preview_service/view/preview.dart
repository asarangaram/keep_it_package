import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../store_service/widgets/get_media_uri.dart';
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
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;
    final child = GetPreviewUri(
      media,
      builder: (uri) => FutureBuilder(
        future: AlbumManager.isPinBroken(media.pin),
        builder: (context, snapshot) {
          return ImageViewerIconView(
            uri: uri,
            fit: fit,
            isPinned: media.pin != null,
            isPinBroken: snapshot.data ?? false,
            overlayIcon: (media.type == CLMediaType.video)
                ? Icons.play_arrow_sharp
                : null,
          );
        },
      ),
    );
    if (!keepAspectRatio) return child;
    return AspectRatio(
      aspectRatio: 1,
      child: child,
    );
  }
}
