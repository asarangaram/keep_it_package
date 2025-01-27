import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import 'builders/available_media.dart';

import 'providers/grouper.dart';
import 'providers/selection_mode.dart';

import 'widgets/actions/bottom_bar.dart';
import 'widgets/actions/top_bar.dart';
import 'widgets/folders_and_files/collection_as_folder.dart';
import 'widgets/folders_and_files/media_as_file.dart';
import 'widgets/when_empty.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends ConsumerWidget {
  const GalleryViewService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );

    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const KeepItTopBar(),
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
                              builder: (clmedias) => KeepItMainGrid(
                                clmedias: clmedias,
                                loadingBuilder: () => CLLoader.widget(
                                  debugMessage: 'KeepItMainGrid',
                                ),
                                errorBuilder: errorBuilder,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  const KeepItBottomBar(),
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
    required this.clmedias,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final CLMedias clmedias;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final method = ref.watch(groupMethodProvider);
    final identifier = ref.watch(mainPageIdentifierProvider);
    final selectionMode = ref.watch(selectModeProvider(identifier));
    return GetStoreUpdater(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (theStore) {
        return GalleryView(
          entities: clmedias.entries,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          parentIdentifier: identifier,
          numColumns: 3,
          selectionMode: selectionMode,
          emptyWidget: const WhenEmpty(),
          onChangeSelectionMode: ({required enable}) {
            ref.read(selectModeProvider(identifier).notifier).state = enable;
          },
          selectionActionsBuilder: (context, entities) {
            final items = entities.map((e) => e as CLMedia).toList();
            return [
              CLMenuItem(
                title: 'Delete',
                icon: clIcons.deleteItem,
                onTap: () async {
                  final confirmed = await DialogService.deleteMediaMultiple(
                        context,
                        ref,
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
          onGroupItems: (entities) => getGrouped(
            entities,
            method: method,
            id: collectionId,
            store: theStore.store,
          ),
          itemBuilder: (
            context,
            item, {
            required parentIdentifier,
          }) =>
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
                parentIdentifier: parentIdentifier,
                onTap: () async {
                  await PageManager.of(context).openMedia(
                    item.id!,
                    collectionId: item.collectionId,
                    parentIdentifier: parentIdentifier,
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

  Future<List<GalleryGroupCLEntity<CLEntity>>> getGrouped(
    List<CLEntity> entities, {
    required GroupTypes method,
    required int? id,
    required Store store,
  }) async {
    final reader = store.reader;
    const columns = 3;
    if (id == null) {
      final ids = entities
          .map((e) => (e as CLMedia).collectionId)
          .where((e) => e != null)
          .map((e) => e!)
          .toSet()
          .toList();
      final collections = await reader.getCollectionsByIDList(ids);
      final grouped = switch (method) {
        GroupTypes.none => collections.group(columns),
        GroupTypes.byOriginalDate => collections.groupByTime(columns),
      };
      return grouped;
    } else {
      final grouped = switch (method) {
        GroupTypes.none => entities.group(columns),
        GroupTypes.byOriginalDate => entities.groupByTime(columns),
      };
      return grouped;
    }
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
