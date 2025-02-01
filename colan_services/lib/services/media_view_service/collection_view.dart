import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../gallery_view_service/builders/available_media.dart';
import 'widgets/cl_media_collage.dart';
import 'widgets/media_preview_service.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView.preview(
    this.collection, {
    required this.viewIdentifier,
    required this.children,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final Collection collection;
  final List<CLMedia> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    final borderColor = collection.hasServerUID
        ? collection.haveItOffline
            ? Colors.blue
            : Colors.green
        : ShadTheme.of(context).colorScheme.foreground;

    return GetFilters(
      identifier: viewIdentifier.parentID,
      builder: (filters) {
        return GetAvailableMediaByCollectionId(
          collectionId: collection.id,
          errorBuilder: (_, __) =>
              throw UnimplementedError('GetMediaByCollectionId'),
          loadingBuilder: () =>
              CLLoader.hide(debugMessage: 'GetMediaByCollectionId'),
          builder: (allMedia) {
            return Padding(
              padding: const EdgeInsets.all(1),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.1),
                      ),
                      child: CLMediaCollage.byMatrixSize(
                        children.length,
                        hCount: 3,
                        vCount: 3,
                        itemBuilder: (context, index) => MediaThumbnail(
                          media: children[index],
                        ),
                        whenNopreview: Center(
                          child: CLText.veryLarge(
                            collection.label.characters.first,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.bottomCenter,
                      child: ShadBadge(
                        backgroundColor:
                            ShadTheme.of(context).colorScheme.mutedForeground,
                        child: Text(
                          collection.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  OverlayWidgets.dimension(
                    alignment: Alignment.bottomRight,
                    sizeFactor: 0.15,
                    child: ShadAvatar(
                      (collection.serverUID == null)
                          ? 'assets/icon/not_on_server.png'
                          : 'assets/icon/cloud_on_lan_128px_color.png',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: (filters.isActive || filters.isTextFilterActive)
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) =>
                                SizeTransition(
                              sizeFactor: animation,
                              child: child,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.bottomCenter,
                              child: FittedBox(
                                child: ShadBadge(
                                  backgroundColor: ShadTheme.of(context)
                                      .colorScheme
                                      .mutedForeground,
                                  child: Text(
                                    '${children.length}/${allMedia.entries.length} matches',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    /* 

    return GetMediaByCollectionId(
      collectionId: collection.id,
      errorBuilder: null,
      loadingBuilder: null,
      builder: (mediaList) {
        final borderColor = collection.hasServerUID
            ? collection.haveItOffline
                ? Colors.blue
                : Colors.green
            : null;
        if (mediaList.isEmpty || true) {
          return Badge.count(
            count: mediaList.entries.length,
            child: CLAspectRationDecorated(
            hasBorder: true,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            borderColor: borderColor,
            child: Center(
              child: CLText.veryLarge(
                collection.label.characters.first,
                ),
              ),
            ),
          );
          
        } else {
          return CLAspectRationDecorated(
            hasBorder: true,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            borderColor: borderColor,
            child: ,
          );
        }
      },
    );*/
  }
}

/* 

          class CollectionPreviewGenerator extends StatelessWidget {
  const CollectionPreviewGenerator({
    required this.collection,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context) {
    return GetMediaByCollectionId(
      collectionId: collection.id,
      buildOnData: (items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CollectionView.preview(collection),
        );
      },
    );
  }
}

*/
