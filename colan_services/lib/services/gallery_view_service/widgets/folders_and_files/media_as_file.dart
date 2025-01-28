import 'dart:async';

import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../media_view_service/media_view_service1.dart';

class MediaAsFile extends StatelessWidget {
  const MediaAsFile({
    required this.media,
    required this.parentIdentifier,
    required this.onTap,
    super.key,
    this.canDuplicateMedia = true,
  });
  final CLMedia media;
  final String parentIdentifier;
  final Future<bool?> Function()? onTap;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context) {
    return GetMedia(
      id: media.id!,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetMedia',
      ),
      errorBuilder: (p0, p1) => const Center(child: Text('getMedia Error')),
      builder: (media0) {
        if (media0 == null) {
          return Container();
        }

        return GetCollection(
          id: media0.collectionId,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetCollection',
          ),
          errorBuilder: (p0, p1) =>
              const Center(child: Text('GetCollection Error')),
          builder: (collection0) {
            final collection = collection0!;

            final haveItOffline = switch (media.type) {
              CLMediaType.image => collection.haveItOffline,
              _ => false
            };

            final isMediaWaitingForDownload = media0.hasServerUID &&
                !media0.isMediaCached &&
                media0.mediaLog == null &&
                haveItOffline;

            return GetStoreUpdater(
              errorBuilder: (_, __) {
                throw UnimplementedError('errorBuilder');
              },
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetStoreUpdater',
              ),
              builder: (theStore) {
                return MediaMenu(
                  onTap: onTap,
                  media: media0,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: MediaViewService1.preview(
                          media0,
                          parentIdentifier: parentIdentifier,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FractionallySizedBox(
                            heightFactor: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                media0.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ShadTheme.of(context)
                                    .textTheme
                                    .small
                                    .copyWith(
                                      backgroundColor: ShadTheme.of(context)
                                          .colorScheme
                                          .foreground
                                          .withValues(alpha: 0.5),
                                      color: ShadTheme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (media.isMediaCached && media.hasServerUID)
                        OverlayWidgets(
                          alignment: Alignment.topLeft,
                          sizeFactor: 0.15,
                          child: const CLIcon.standard(
                            Icons.check_circle,
                            color: Colors.blue,
                          ),
                        )
                      else if (isMediaWaitingForDownload)
                        OverlayWidgets(
                          alignment: Alignment.topLeft,
                          sizeFactor: 0.15,
                          child: const CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
