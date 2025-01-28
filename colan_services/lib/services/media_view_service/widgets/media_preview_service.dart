import 'dart:math' as math;

import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaPreviewService extends StatelessWidget {
  const MediaPreviewService({
    required this.media,
    required this.parentIdentifier,
    required this.autoStart,
    required this.autoPlay,
    required this.onLockPage,
    required this.isLocked,
    super.key,
  });

  final CLMedia media;
  final String parentIdentifier;
  final bool autoStart;
  final bool autoPlay;
  final void Function({required bool lock})? onLockPage;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return GetStoreUpdater(
      errorBuilder: BrokenImage.show,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return GetPreviewUri(
          errorBuilder: BrokenImage.show,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetPreviewUri',
          ),
          id: media.id!,
          builder: (previewUri) {
            /* log(
              'preview URI: $previewUri',
              name: 'MediaView | build',
            ); */
            return Hero(
              tag: '$parentIdentifier /item/${media.id}',
              child: ImageViewer.basic(
                uri: previewUri,
                autoStart: autoStart,
                autoPlay: autoPlay,
                onLockPage: onLockPage,
                isLocked: isLocked,
                fit: BoxFit.cover,
                overlays: [
                  if (media.serverUID != null)
                    OverlayWidgets(
                      alignment: Alignment.bottomRight,
                      sizeFactor: 0.2,
                      child: const ShadAvatar(
                        'assets/icon/cloud_on_lan_128px_color.png',
                      ),
                    ),
                  if (media.pin != null)
                    OverlayWidgets(
                      alignment: Alignment.bottomRight,
                      sizeFactor: 0.2,
                      child: FutureBuilder(
                        future: theStore.albumManager.isPinBroken(media.pin),
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
                  if (media.type == CLMediaType.video)
                    OverlayWidgets(
                      alignment: Alignment.center,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Theme.of(context).colorScheme.onSurface.withAlpha(
                                    192,
                                  ), // Color for the circular container
                        ),
                        child: CLIcon.veryLarge(
                          clIcons.playerPlay,
                          color:
                              CLTheme.of(context).colors.iconColorTransparent,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
