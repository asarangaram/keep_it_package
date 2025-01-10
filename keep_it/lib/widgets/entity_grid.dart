import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/when_empty.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../builders/grouper.dart';
import '../navigation/providers/active_collection.dart';
import 'folders_and_files/collection_as_folder.dart';
import 'folders_and_files/media_as_file.dart';

class EntityGrid extends ConsumerWidget {
  const EntityGrid({
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identifier = ref.watch(mainPageIdentifierProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: entities.isEmpty
            ? const WhenEmpty()
            : GetFilterredMedia(
                errorBuilder: errorBuilder,
                loadingBuilder: loadingBuilder,
                incoming: entities,
                builder: (filterred) {
                  return filterred.isEmpty
                      ? Center(
                          child: FilterCount(
                            total: entities.length,
                            filterred: filterred.length,
                          ),
                        )
                      : GetGroupedMedia(
                          incoming: filterred,
                          columns: 4,
                          builder: (galleryMap) {
                            return CLEntityGridView(
                              identifier: identifier,
                              galleryMap: galleryMap,
                              topWidget: Align(
                                alignment: Alignment.centerRight,
                                child: FilterCount(
                                  total: entities.length,
                                  filterred: filterred.length,
                                ),
                              ),
                              itemBuilder: (context, item) =>
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
                                    parentIdentifier: identifier,
                                    onTap: () async {
                                      await PageManager.of(context, ref)
                                          .openMedia(
                                        item.id!,
                                        collectionId: item.collectionId,
                                        parentIdentifier: identifier,
                                      );
                                      return true;
                                    },
                                  ),
                                _ => throw UnimplementedError(),
                              },
                              columns: 4,
                            );
                          },
                        );
                },
              ),
      ),
    );
  }
}

class FilterCount extends ConsumerWidget {
  const FilterCount({required this.total, required this.filterred, super.key});
  final int total;
  final int filterred;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topMsg = (filterred < total)
        ? ' $filterred out of '
            '$total is Shown.'
        : null;
    if (topMsg == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.onSurface,
        child: CLText.tiny(
          topMsg,
          color: Theme.of(context).colorScheme.surfaceBright,
        ),
      ),
    );
  }
}

class CLEntityGridView extends ConsumerWidget {
  const CLEntityGridView({
    required this.identifier,
    required this.itemBuilder,
    required this.galleryMap,
    required this.columns,
    required this.topWidget,
    super.key,
  });
  final String identifier;
  final List<GalleryGroupCLEntity<CLEntity>> galleryMap;
  final ItemBuilder itemBuilder;
  final int columns;
  final Widget topWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: galleryMap.length + 1,
      itemBuilder: (BuildContext context, int groupIndex) {
        if (groupIndex == 0) {
          return topWidget;
        }
        final gallery = galleryMap[groupIndex - 1];
        final labelWidget = gallery.label == null
            ? null
            : CLText.large(
                gallery.label!,
                textAlign: TextAlign.start,
              );
        return CLGrid<CLEntity>(
          itemCount: gallery.items.length,
          columns: columns,
          itemBuilder: (context, itemIndex) {
            final itemWidget = itemBuilder(
              context,
              gallery.items[itemIndex],
            );

            return itemWidget;
          },
          header: gallery.label == null ? null : labelWidget,
        );
      },
    );
  }
}
