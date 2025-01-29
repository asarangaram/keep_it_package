import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../../builders/get_parent_identifier.dart';
import 'builders/available_media.dart';

import 'widgets/actions/bottom_bar.dart';
import 'widgets/actions/top_bar.dart';
import 'widgets/folders_and_files/collection_as_folder.dart';
import 'widgets/folders_and_files/media_as_file.dart';
import 'widgets/when_empty.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends StatelessWidget {
  const GalleryViewService({
    super.key,
    this.parentIdentifier = 'MainView',
  });
  final String parentIdentifier;
  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );

    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                KeepItTopBar(
                  parentIdentifier: parentIdentifier,
                ),
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
                            parentIdentifier: parentIdentifier,
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
    final identifier = ref.watch(mainPageIdentifierProvider);
    final selectionMode = ref.watch(selectModeProvider(identifier));
    return GetStoreUpdater(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (theStore) {
        return GalleryView(
          onClose: () {
            ref.read(selectModeProvider(identifier).notifier).state =
                !selectionMode;
          },
          parentIdentifier: parentIdentifier,
          entities: clmedias.entries,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
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
            CLMedia _ => GetParentIdentifier(
                builder: (parentIdentifier) {
                  return MediaAsFile(
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
                  );
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
