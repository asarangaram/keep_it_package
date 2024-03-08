// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../providers/gallery_group_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/media_as_file.dart';

class TimeLinePage extends StatelessWidget {
  const TimeLinePage({required this.collectionId, super.key});

  final int collectionId;

  @override
  Widget build(BuildContext context) => GetCollection(
        id: collectionId,
        buildOnData: (collection) => GetMediaMultiple(
          collectionId: collectionId,
          buildOnData: (items) =>
              TimeLinePage0(collection: collection, items: items),
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
    final label = collection?.label ?? 'All Media';
    return CLSimpleGalleryView(
      key: ValueKey(label),
      label: label,
      tagPrefix: 'TimeLinePage0 $label',
      columns: 4,
      galleryMap: galleryGroups,
      emptyState: const EmptyState(),
      itemBuilder: (context, item, {required quickMenuScopeKey}) => MediaAsFile(
        media: item as CLMedia,
        quickMenuScopeKey: quickMenuScopeKey,
      ),
      onPickFiles: () async => onPickFiles(
        context,
        ref,
        collection: collection,
      ),
      onRefresh: () async => ref.invalidate(dbManagerProvider),
      onPop: context.canPop() ? () => context.pop() : null,
    );
  }
}
