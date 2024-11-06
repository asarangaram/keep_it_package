import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.parentIdentifier,
    required this.quickMenuScopeKey,
    required this.onTap,
    required this.actionControl,
    super.key,
  });
  final CLMedia media;
  final String parentIdentifier;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  final ActionControl actionControl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMedia(
      id: media.id!,
      loadingBuilder: Container.new,
      errorBuilder: (p0, p1) => Container(),
      builder: (media0) {
        if (media0 == null) {
          return Container();
        }
        final readOnly =
            (media0.type == CLMediaType.video && !VideoEditor.isSupported) ||
                (!media0.isMediaCached || !media0.isMediaOriginal);
        return GetCollection(
          id: media0.id,
          loadingBuilder: Container.new,
          errorBuilder: (p0, p1) => Container(),
          builder: (collection) {
            final isMediaWaitingForDownload = !media0.isMediaCached &&
                media0.mediaLog == null &&
                (media0.haveItOffline ?? collection?.haveItOffline ?? false);

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
                  onEdit: readOnly
                      ? null
                      : () async {
                          /* final updatedMedia =  */ await Navigators
                              .openEditor(
                            context,
                            ref,
                            media0,
                            canDuplicateMedia: actionControl.canDuplicateMedia,
                          );
                          return true;
                        },
                  onDeleteLocalCopy: () async {
                    await theStore.mediaUpdater.deleteLocalCopy(media0);
                    ref.read(serverProvider.notifier).sync();
                    return true;
                  },
                  onKeepOffline: () async {
                    await theStore.mediaUpdater.markHaveItOffline(media0);
                    ref.read(serverProvider.notifier).downloadMediaFile(media0);
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
