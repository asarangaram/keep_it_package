// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionID, super.key});
  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadItems(
        collectionID: collectionID,
        buildOnData: (items) {
          final galleryGroups = <GalleryGroup>[];
          for (final entry in items.entries.filterByDate().entries) {
            galleryGroups.add(GalleryGroup(entry.value, label: entry.key));
          }
          return CLGalleryView(
            label: items.collection.label,
            galleryMap: galleryGroups,
            emptyState: const EmptyState(),
            itemBuilder: (context, item) {
              final media = item as CLMedia;
              return GestureDetector(
                onTap: () {
                  context.push('/item/${media.collectionId}/${media.id}');
                },
                child: CLMediaPreview(
                  media: media,
                ),
              );
            },
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

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  static Widget? cache;
  @override
  Widget build(BuildContext context) {
    return cache ??= const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CLText.large(
          'Nothing to see here',
        ),
      ),
    );
  }
}
