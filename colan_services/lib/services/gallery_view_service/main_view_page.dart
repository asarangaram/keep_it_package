import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import 'builders/available_media.dart';

import 'providers/active_collection.dart';
import 'widgets/actions/bottom_bar.dart';
import 'widgets/actions/top_bar.dart';
import 'widgets/folders_and_files/collection_as_folder.dart';
import 'widgets/folders_and_files/media_as_file.dart';
import 'widgets/when_empty.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends StatelessWidget {
  const GalleryViewService({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );
    const parentIdentifier = 'KeepItMainGrid';

    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: GetStore(
                    errorBuilder: errorBuilder,
                    loadingBuilder: () => CLLoader.widget(
                      debugMessage: 'GetStore',
                    ),
                    builder: (store) {
                      return RefreshIndicator(
                        onRefresh: /* isSelectionMode ? null : */
                            () async => store.reloadStore(),
                        child: GetAvailableMediaByCollectionId(
                          loadingBuilder: () => CLLoader.widget(
                            debugMessage: 'GetAvailableMediaByCollectionId',
                          ),
                          errorBuilder: errorBuilder,
                          builder: (clmedias) => Column(
                            children: [
                              const KeepItTopBar(
                                parentIdentifier: parentIdentifier,
                              ),
                              Expanded(
                                child: KeepItMainGrid(
                                  parentIdentifier: parentIdentifier,
                                  clmedias: clmedias,
                                  loadingBuilder: () => CLLoader.widget(
                                    debugMessage: 'KeepItMainGrid',
                                  ),
                                  errorBuilder: errorBuilder,
                                ),
                              ),
                              if (MediaQuery.of(context).viewInsets.bottom == 0)
                                const KeepItBottomBar(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Area with Three FABs
      ),
    );
  }
}

class KeepItMainGrid extends ConsumerWidget {
  const KeepItMainGrid({
    required this.parentIdentifier,
    required this.clmedias,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final String parentIdentifier;
  final CLMedias clmedias;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: collectionId.toString(),
    );
    return GetStoreUpdater(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (theStore) {
        return CLEntityGalleryView(
          viewIdentifier: viewIdentifier,
          entities: clmedias.entries,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          numColumns: 3,
          emptyWidget: const WhenEmpty(),
          selectionActionsBuilder: (context, entities) {
            final items = entities.map((e) => e as CLMedia).toList();
            return [
              CLMenuItem(
                title: 'Delete',
                icon: clIcons.deleteItem,
                onTap: () async {
                  final confirmed = await DialogService.deleteMediaMultiple(
                        context,
                        media: items,
                      ) ??
                      false;
                  if (!confirmed) return confirmed;
                  if (context.mounted) {
                    return theStore.mediaUpdater.deleteMultiple(
                      {...items.map((e) => e.id!)},
                    );
                  }
                  return null;
                },
              ),
              CLMenuItem(
                title: 'Move',
                icon: clIcons.imageMoveAll,
                onTap: () => MediaWizardService.openWizard(
                  context,
                  ref,
                  CLSharedMedia(
                    entries: items,
                    type: UniversalMediaSource.move,
                  ),
                ),
              ),
              CLMenuItem(
                title: 'Share',
                icon: clIcons.imageShareAll,
                onTap: () => theStore.mediaUpdater.share(context, items),
              ),
              if (ColanPlatformSupport.isMobilePlatform)
                CLMenuItem(
                  title: 'Pin',
                  icon: clIcons.pinAll,
                  onTap: () => theStore.mediaUpdater.pinToggleMultiple(
                    items.map((e) => e.id).toSet(),
                    onGetPath: (media) {
                      throw UnimplementedError(
                        'onGetPath not yet implemented',
                      );
                    },
                  ),
                ),
            ];
          },
          itemBuilder: (
            context,
            item,
          ) =>
              switch (item) {
            Collection _ => CollectionAsFolder(
                collection: item,
                onTap: () {
                  ref
                      .read(
                        activeCollectionProvider.notifier,
                      )
                      .state = item.id;
                },
              ),
            CLMedia _ => MediaAsFile(
                media: item,
                parentIdentifier: viewIdentifier.toString(),
                onTap: () async {
                  await PageManager.of(context).openMedia(
                    item.id!,
                    collectionId: item.collectionId,
                    parentIdentifier: viewIdentifier.toString(),
                  );
                  return true;
                },
              ),
            _ => throw UnimplementedError(),
          },
        );
      },
    );
  }
}

class OnSwipe extends ConsumerWidget {
  const OnSwipe({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (collectionId != null) {
            ref.read(activeCollectionProvider.notifier).state = null;
          }
        }
      },
      child: child,
    );
  }
}
