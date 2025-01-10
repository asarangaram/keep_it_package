import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/when_empty.dart';
import 'package:store/store.dart';

import '../navigation/providers/active_collection.dart';
import 'folders_and_files/collection_as_folder.dart';
import 'folders_and_files/media_as_file.dart';

class EntityGrid extends ConsumerWidget {
  const EntityGrid({required this.entities, super.key});
  final List<CLEntity> entities;

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
            : CLEntityGridView(
                identifier: identifier,
                items: entities,
                itemBuilder: (context, item) => switch (item.runtimeType) {
                  Collection => CollectionAsFolder(
                      collection: item as Collection,
                      onTap: () {
                        ref.read(activeCollectionProvider.notifier).state =
                            item.id;
                      },
                    ),
                  CLMedia => MediaAsFile(
                      media: item as CLMedia,
                      parentIdentifier: identifier,
                      onTap: () async {
                        await PageManager.of(context, ref).openMedia(
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
              ),
      ),
    );
  }
}

class CLEntityGridView extends ConsumerWidget {
  const CLEntityGridView({
    required this.identifier,
    required this.itemBuilder,
    required this.items,
    required this.columns,
    super.key,
  });
  final String identifier;
  final List<CLEntity> items;
  final ItemBuilder itemBuilder;
  final int columns;

  List<GalleryGroupCLEntity<CLEntity>> group(List<CLEntity> entities) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    for (final rows in entities.convertTo2D(columns)) {
      galleryGroups.add(
        GalleryGroupCLEntity(
          rows,
          label: null,
          groupIdentifier: 'Collections',
          chunkIdentifier: 'Collections',
        ),
      );
    }
    return galleryGroups;
  }

  List<GalleryGroupCLEntity<CLEntity>> groupByTime(List<CLEntity> entities) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    if (entities.first.runtimeType == Collection) {
      return group(entities);
    }

    for (final entry in entities.filterByDate().entries) {
      if (entry.value.length > 20) {
        final groups = entry.value.convertTo2D(20);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            GalleryGroupCLEntity(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          GalleryGroupCLEntity(
            entry.value,
            label: entry.key,
            groupIdentifier: entry.key,
            chunkIdentifier: entry.key,
          ),
        );
      }
    }
    return galleryGroups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryMap = groupByTime(items);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: galleryMap.length,
      itemBuilder: (BuildContext context, int groupIndex) {
        final gallery = galleryMap[groupIndex];
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
