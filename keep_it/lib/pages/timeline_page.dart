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
  Widget build(BuildContext context, WidgetRef ref) => GetCollectionMultiple(
        buildOnData: (collections) {
          return GetCollection(
            id: collectionId,
            buildOnData: (collection) {
              return GetMediaMultiple(
                collectionId: collectionId,
                buildOnData: (items) {
                  final galleryGroups = <GalleryGroup>[];
                  for (final entry in items.filterByDate().entries) {
                    galleryGroups.add(
                      GalleryGroup(
                        entry.value,
                        label: entry.key,
                      ),
                    );
                  }
                  return CLGalleryView(
                    key: ValueKey(collection?.label ?? 'All Media'),
                    columns: 4,
                    label: collection?.label ?? 'All Media',
                    galleryMap: galleryGroups,
                    emptyState: const EmptyState(),
                    isScrollablePositionedList: false,
                    labelTextBuilder: (index) =>
                        galleryGroups[index].label ?? '',
                    itemBuilder: (
                      context,
                      item, {
                      required quickMenuScopeKey,
                    }) =>
                        MediaAsFile(
                      media: item as CLMedia,
                      quickMenuScopeKey: quickMenuScopeKey,
                    ),
                    tagPrefix: 'timeline $collectionId',
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
                },
              );
            },
          );
        },
      );
}
