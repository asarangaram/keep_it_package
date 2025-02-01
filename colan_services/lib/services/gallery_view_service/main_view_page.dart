import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../context_menu_service/models/context_menu_items.dart';

import '../context_menu_service/widgets/pull_down_context_menu.dart';
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
    if (clmedias.isEmpty && collectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeCollectionProvider.notifier).state = null;
      });
    }
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
          viewableAsCollection: true,
          emptyWidget: const WhenEmpty(),
          contextMenuBuilder: (context, entities) {
            return switch (entities) {
              final List<CLEntity> e when e.every((e) => e is CLMedia) => () {
                  return CLContextMenu.ofMultipleMedia(
                    context,
                    ref,
                    items: e.map((e) => e as CLMedia).toList(),
                    hasOnlineService: true,
                    theStore: theStore,
                  );
                }(),
              final List<CLEntity> e when e.every((e) => e is Collection) =>
                () {
                  return CLContextMenu.empty();
                }(),
              _ => throw UnimplementedError('Mix of items not supported yet')
            };
          },
          itemBuilder: (
            context,
            item,
          ) {
            final canSync = ref.watch(
              serverProvider.select((server) => server.canSync),
            );

            return switch (item) {
              Collection _ => PullDownContextMenu(
                  onTap: () async {
                    ref
                        .read(
                          activeCollectionProvider.notifier,
                        )
                        .state = item.id;
                    return null;
                  },
                  contextMenu: CLContextMenu.ofCollection(
                    context,
                    ref,
                    collection: item,
                    hasOnlineService: canSync,
                    theStore: theStore,
                  ),
                  child: CollectionAsFolder(
                    parentIdentifier: viewIdentifier.toString(),
                    collection: item,
                  ),
                ),
              CLMedia _ => GetCollection(
                  id: item.collectionId,
                  loadingBuilder: () =>
                      CLLoader.widget(debugMessage: 'GetCollection'),
                  errorBuilder: (p0, p1) =>
                      const Center(child: Text('GetCollection Error')),
                  builder: (parentCollection) {
                    final canSync = ref.watch(
                      serverProvider.select((server) => server.canSync),
                    );
                    return PullDownContextMenu(
                      onTap: () async {
                        await PageManager.of(context).openMedia(
                          item.id!,
                          collectionId: item.collectionId,
                          parentIdentifier: viewIdentifier.toString(),
                        );
                        return true;
                      },
                      contextMenu: CLContextMenu.ofMedia(
                        context,
                        ref,
                        media: item,
                        parentCollection: parentCollection!,
                        hasOnlineService: canSync,
                        theStore: theStore,
                      ),
                      child: MediaPreviewWithOverlays(
                        media: item,
                        parentCollection: parentCollection,
                        parentIdentifier: viewIdentifier.toString(),
                      ),
                    );
                  },
                ),
              _ => throw UnimplementedError(),
            };
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
