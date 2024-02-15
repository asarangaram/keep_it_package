// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/load_items.dart';



class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionID, super.key});
  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadItems(
        collectionID: collectionID,
        buildOnData: (items) {
          return CLGalleryView(
            label: items.collection.label,
            galleryMap: items.entries.filterByDate(),
            emptyState: const EmptyState(),
            tagPrefix: 'timeline ${items.collection.id}',
            onPickFiles: () async {
              await onPickFiles(
                context,
                ref,
                collectionId: items.collection.id,
              );
            },
            onTapMedia: (CLMedia media) =>
                context.push('/item/${media.collectionId}/${media.id}'),
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
