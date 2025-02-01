import 'dart:async';

import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../context_menu_service/models/context_menu_items.dart';
import '../../../context_menu_service/widgets/pull_down_context_menu.dart';
import '../../../media_view_service/widgets/media_preview_service.dart';

class MediaPreview extends StatelessWidget {
  const MediaPreview({
    required this.media,
    required this.parentIdentifier,
    this.onTap,
    this.contextMenu,
    super.key,
  });
  final CLMedia media;
  final String parentIdentifier;
  final Future<bool?> Function()? onTap;

  final CLContextMenu? contextMenu;

  @override
  Widget build(BuildContext context) {
    return GetMedia(
      id: media.id!,
      loadingBuilder: () => CLLoader.widget(debugMessage: 'GetMedia'),
      errorBuilder: (p0, p1) => const Center(child: Text('getMedia Error')),
      builder: (media0) {
        if (media0 == null) return const Center(child: Text('getMedia Error'));

        return GetCollection(
          id: media0.collectionId,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetCollection',
          ),
          errorBuilder: (p0, p1) =>
              const Center(child: Text('GetCollection Error')),
          builder: (collection) {
            final parentCollection = collection!;

            return PullDownContextMenu(
              onTap: onTap,
              contextMenu: contextMenu,
              child: MediaPreview0(
                media: media0,
                parentCollection: parentCollection,
                parentIdentifier: parentIdentifier,
              ),
            );
          },
        );
      },
    );
  }
}

class MediaPreview0 extends StatelessWidget {
  const MediaPreview0({
    required this.parentIdentifier,
    required this.media,
    required this.parentCollection,
    super.key,
  });
  final CLMedia media;
  final Collection parentCollection;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    final haveItOffline = switch (media.type) {
      CLMediaType.image => parentCollection.haveItOffline,
      _ => false
    };
    final isMediaWaitingForDownload = media.hasServerUID &&
        !media.isMediaCached &&
        media.mediaLog == null &&
        haveItOffline;

    return Stack(
      children: [
        Positioned.fill(
          child: MediaPreviewService(
            media: media,
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
                  media.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShadTheme.of(context).textTheme.small.copyWith(
                        backgroundColor: ShadTheme.of(context)
                            .colorScheme
                            .foreground
                            .withValues(alpha: 0.5),
                        color: ShadTheme.of(context).colorScheme.background,
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
    );
  }
}
