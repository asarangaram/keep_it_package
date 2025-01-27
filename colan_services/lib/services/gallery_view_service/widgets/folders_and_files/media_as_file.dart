import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../media_view_service/media_view_service1.dart';

class MediaAsFile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Column(
                    children: [
                      Expanded(
                        child: MediaViewService1.preview(
                          media0,
                          parentIdentifier: parentIdentifier,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 2,
                          bottom: 2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                child: Text(
                                  media0.name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox.square(
                              dimension: 20,
                              child: Image.asset(
                                (media0.serverUID == null)
                                    ? 'assets/icon/not_on_server.png'
                                    : 'assets/icon/cloud_on_lan_128px_color.png',
                              ),
                            ),
                            if (media0.isMediaCached && media0.hasServerUID)
                              const SizedBox.square(
                                dimension: 10,
                                child: FittedBox(
                                  child: CLIcon.standard(Icons.check_circle),
                                ),
                              )
                            else if (isMediaWaitingForDownload)
                              const SizedBox.square(
                                dimension: 10,
                                child: FittedBox(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
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
