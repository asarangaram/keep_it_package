// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/item_file_view.dart';

class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionID, super.key});
  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadItems(
        collectionID: collectionID,
        buildOnData: (items) {
          final galleryGroups = <GalleryGroup>[];
          for (final entry in items.entries.filterByDate().entries) {
            galleryGroups.add(
              GalleryGroup(
                entry.value,
                label: entry.key,
              ),
            );
          }
          return CLGalleryView(
            columns: 4,
            label: items.collection.label,
            galleryMap: galleryGroups,
            emptyState: const EmptyState(),
            labelTextBuilder: (index) => galleryGroups[index].label ?? '',
            itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                MediaAsFile(
              media: item as CLMedia,
              quickMenuScopeKey: quickMenuScopeKey,
            ),
            tagPrefix: 'timeline ${items.collection.id}',
            onPickFiles: () async {
              await onPickFiles(
                context,
                ref,
                collectionId: items.collection.id,
              );
            },
            onPop: context.canPop()
                ? () {
                    context.pop();
                  }
                : null,
          );
        },
      );
}
