import 'dart:io';
import 'dart:math' as math;

import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaPreviewWithOverlays extends StatelessWidget {
  const MediaPreviewWithOverlays({
    required this.media,
    required this.parentIdentifier,
    super.key,
  });

  final StoreEntity media;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '$parentIdentifier /item/${media.id}',
      child: MediaThumbnail(
        media: media,
        overlays: [
          OverlayWidgets(
            heightFactor: 0.2,
            alignment: Alignment.bottomCenter,
            fit: BoxFit.none,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: ShadTheme.of(context)
                  .colorScheme
                  .foreground
                  .withValues(alpha: 0.5),
              child: Text(
                media.data.label ?? 'Unnamed',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ShadTheme.of(context).textTheme.small.copyWith(
                      color: ShadTheme.of(context).colorScheme.background,
                    ),
              ),
            ),
          ),
          if (media.data.pin != null)
            OverlayWidgets.dimension(
              alignment: Alignment.bottomRight,
              sizeFactor: 0.15,
              child: FutureBuilder(
                future: isPinBroken(media.data.pin),
                builder: (context, snapshot) {
                  return Transform.rotate(
                    angle: math.pi / 4,
                    child: CLIcon.veryLarge(
                      snapshot.data ?? false
                          ? clIcons.brokenPin
                          : clIcons.pinned,
                      color: snapshot.data ?? false
                          ? Colors.red
                          : const Color.fromARGB(255, 33, 243, 47),
                    ),
                  );
                },
              ),
            ),
          if (media.data.mediaType == CLMediaType.video)
            OverlayWidgets.dimension(
              alignment: Alignment.center,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(
                        192,
                      ), // Color for the circular container
                ),
                child: CLIcon.veryLarge(
                  clIcons.playerPlay,
                  color: CLTheme.of(context).colors.iconColorTransparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({
    required this.media,
    this.overlays,
    super.key,
  });
  final StoreEntity media;
  final List<OverlayWidgets>? overlays;

  @override
  Widget build(BuildContext context) {
    if (media.previewUri == null) {
      return const BrokenImage();
    }
    if (!File(media.mediaUri!.toFilePath()).existsSync()) {
      return const BrokenImage();
    }
    try {
      return ImageViewer.basic(
        uri: media.previewUri!,
        fit: BoxFit.cover,
        overlays: overlays,
        brokenImage: const BrokenImage(),
        loadingWidget: const GreyShimmer(),
        keepAspectRatio: false,
      );
    } catch (e) {
      return const BrokenImage();
    }
  }
}

Future<bool> isPinBroken(String? pin) {
  throw UnimplementedError();
}
