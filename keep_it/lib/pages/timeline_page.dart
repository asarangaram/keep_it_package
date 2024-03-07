// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/media_as_file.dart';

class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionId, super.key});
  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GetCollection(
        id: collectionId,
        buildOnData: (collection) => GetMediaMultiple(
          collectionId: collectionId,
          buildOnData: (items) => TimeLinePage0(
            collection: collection,
            items: items,
          ),
        ),
      );
}

class TimeLinePage0 extends ConsumerWidget {
  const TimeLinePage0({
    required this.collection,
    required this.items,
    super.key,
  });

  final Collection? collection;
  final List<CLMedia> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryGroups = ref.watch(groupedItemsProvider(items));
    return CLGalleryView(
      key: ValueKey(collection?.label ?? 'All Media'),
      columns: 4,
      label: collection?.label ?? 'All Media',
      galleryMap: galleryGroups,
      emptyState: const EmptyState(),
      labelTextBuilder: (index) => galleryGroups[index].label ?? '',
      itemBuilder: (
        context,
        item, {
        required quickMenuScopeKey,
      }) =>
          MediaAsFile(
        media: item as CLMedia,
        quickMenuScopeKey: quickMenuScopeKey,
      ),
      tagPrefix: 'timeline ${collection?.id}',
      onPickFiles: () async {
        await onPickFiles(
          context,
          ref,
          collection: collection,
        );
      },
      onRefresh: () async {
        ref.invalidate(dbManagerProvider);
      },
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
    );
  }
}

final groupedItemsProvider =
    StateProvider.family<List<GalleryGroup>, List<CLMedia>>((ref, items) {
  final galleryGroups = <GalleryGroup>[];
  for (final entry in items.filterByDate().entries) {
    galleryGroups.add(
      GalleryGroup(
        entry.value,
        label: entry.key,
      ),
    );
  }
  return galleryGroups;
});
