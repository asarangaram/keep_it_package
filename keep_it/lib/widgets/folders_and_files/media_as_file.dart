import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.parentIdentifier,
    required this.quickMenuScopeKey,
    required this.onTap,
    super.key,
  });
  final CLMedia media;
  final String parentIdentifier;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMedia(
      id: media.id!,
      loadingBuilder: () => const Center(child: Text('getMedia')),
      errorBuilder: (p0, p1) => const Center(child: Text('getMedia Error')),
      builder: (media0) {
        if (media0 == null) {
          return Container();
        }
        final ac = AccessControlExt.onGetMediaActionControl(media0);

        return GetCollection(
          id: media0.collectionId,
          loadingBuilder: () => const Center(child: Text('GetCollection')),
          errorBuilder: (p0, p1) =>
              const Center(child: Text('GetCollection Error')),
          builder: (collection0) {
            final collection = collection0!;

            final haveItOffline =
                media0.haveItOffline ?? collection.haveItOffline;

            final isMediaWaitingForDownload = media0.hasServerUID &&
                !media0.isMediaCached &&
                media0.mediaLog == null &&
                haveItOffline;

            return GetStoreUpdater(
              builder: (theStore) {
                return MediaMenu(
                  onMove: () => MediaWizardService.openWizard(
                    context,
                    ref,
                    CLSharedMedia(
                      entries: [media0],
                      type: UniversalMediaSource.move,
                    ),
                  ),
                  onDelete: () async {
                    return theStore.mediaUpdater.delete(media0.id!);
                  },
                  onShare: media0.isMediaCached
                      ? () => theStore.mediaUpdater.share(context, [media0])
                      : null,
                  onEdit: () async {
                    await Navigators.openEditor(
                      context,
                      ref,
                      media0,
                      canDuplicateMedia: ac.canDuplicateMedia,
                    );
                    return true;
                  },
                  onDeleteLocalCopy: () async {
                    await theStore.mediaUpdater
                        .deleteLocalCopy(media0, shouldRefresh: false);
                    ref.read(serverProvider.notifier).instantSync();
                    return true;
                  },
                  onKeepOffline: () async {
                    final mediaInDB = await theStore.mediaUpdater
                        .markHaveItOffline(media0, shouldRefresh: false);
                    if (mediaInDB != null) {
                      ref
                          .read(serverProvider.notifier)
                          .downloadMediaFile(mediaInDB);
                    }

                    return true;
                  },
                  onTap: onTap,
                  media: media0,
                  child: Column(
                    children: [
                      Expanded(
                        child: MediaViewService.preview(
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
                            if (media0.isMediaCached)
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
