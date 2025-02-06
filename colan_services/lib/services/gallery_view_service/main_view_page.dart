import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../context_menu_service/models/context_menu_items.dart';

import '../media_view_service/preview/entity_preview.dart';
import 'builders/available_media.dart';

import 'providers/active_collection.dart';
import 'widgets/actions/bottom_bar.dart';
import 'widgets/actions/top_bar.dart';

import 'widgets/when_empty.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends StatelessWidget {
  const GalleryViewService({super.key});

  @override
  Widget build(BuildContext context) {
    return const CLMainScaffold();
  }
}

class CLMainScaffold extends StatelessWidget {
  const CLMainScaffold({
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
            child: GetStoreUpdater(
              errorBuilder: errorBuilder,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetStore',
              ),
              builder: (theStore) {
                return GetAvailableMediaByActiveCollectionId(
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetAvailableMediaByCollectionId',
                  ),
                  errorBuilder: errorBuilder,
                  builder: (clmedias) => Column(
                    children: [
                      KeepItTopBar(
                        parentIdentifier: parentIdentifier,
                        clmedias: clmedias,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: /* isSelectionMode ? null : */
                              () async => theStore.store.reloadStore(),
                          child: KeepItMainGrid(
                            parentIdentifier: parentIdentifier,
                            clmedias: clmedias,
                            theStore: theStore,
                            loadingBuilder: () => CLLoader.widget(
                              debugMessage: 'KeepItMainGrid',
                            ),
                            errorBuilder: errorBuilder,
                          ),
                        ),
                      ),
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        const KeepItBottomBar(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class KeepItMainGrid extends ConsumerWidget {
  const KeepItMainGrid({
    required this.parentIdentifier,
    required this.clmedias,
    required this.theStore,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final String parentIdentifier;
  final CLMedias clmedias;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final StoreUpdater theStore;

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
    return CLEntityGalleryView(
      viewIdentifier: viewIdentifier,
      entities: clmedias.entries,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      bannersBuilder: (context, _) {
        return [
          if (collectionId == null) const StaleMediaIndicatorService(),
        ];
      },
      columns: 3,
      viewableAsCollection: collectionId == null,
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
          final List<CLEntity> e when e.every((e) => e is Collection) => () {
              return CLContextMenu.empty();
            }(),
          _ => throw UnimplementedError('Mix of items not supported yet')
        };
      },
      itemBuilder: (
        context,
        item, {
        required CLEntity? Function(CLEntity entity)? onGetParent,
        required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
      }) =>
          EntityPreview(
        viewIdentifier: viewIdentifier,
        item: item,
        theStore: theStore,
        onGetChildren: onGetChildren,
        onGetParent: onGetParent,
      ),
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
