import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/when_empty.dart';
import 'package:store/store.dart';

import '../builders/available_media.dart';
import '../navigation/providers/active_collection.dart';

import '../navigation/providers/grouper.dart';
import '../navigation/providers/selection_mode.dart';
import '../widgets/actions/bottom_bar.dart';
import '../widgets/actions/top_bar.dart';

import '../widgets/folders_and_files/collection_as_folder.dart';
import '../widgets/folders_and_files/media_as_file.dart';
import '../widgets/utils/error_view.dart';
import '../widgets/utils/loading_view.dart';

class MainViewPage extends ConsumerWidget {
  const MainViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) =>
        ErrorView(error: e, stackTrace: st);
    const Widget loadingWidget = LoadingView();
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
                        builder: (store) {
                          return RefreshIndicator(
                            onRefresh: /* isSelectionMode ? null : */
                                () async => store.reloadStore(),
                            child: GetAvailableMediaByCollectionId(
                              loadingBuilder: () => loadingWidget,
                              errorBuilder: errorBuilder,
                              builder: (clmedias) => KeepItMainGrid(
                                clmedias: clmedias,
                                loadingBuilder: () => loadingWidget,
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
    return GetStore(
      builder: (store) {
        return CLEntityGrid(
          entities: clmedias.entries,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          parentIdentifier: identifier,
          numColumns: 3,
          selectionMode: selectionMode,
          whenEmpty: const WhenEmpty(),
          onChangeSelectionMode: ({required enable}) {
            ref.read(selectModeProvider(identifier).notifier).state = enable;
          },
          getGrouped: (entities) => getGrouped(
            entities,
            method: method,
            id: collectionId,
            store: store,
          ),
          itemBuilder: (
            context,
            item, {
            required parentIdentifier,
          }) =>
              switch (item.runtimeType) {
            Collection => CollectionAsFolder(
                collection: item as Collection,
                onTap: () {
                  ref
                      .read(
                        activeCollectionProvider.notifier,
                      )
                      .state = item.id;
                },
              ),
            CLMedia => MediaAsFile(
                media: item as CLMedia,
                parentIdentifier: parentIdentifier,
                onTap: () async {
                  await PageManager.of(context, ref).openMedia(
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
