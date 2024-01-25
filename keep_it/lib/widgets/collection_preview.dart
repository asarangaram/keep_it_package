import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/media_preview.dart';
import 'package:store/store.dart';

import 'from_store/items_in_collection.dart';

class CollectionPreview extends ConsumerWidget {
  const CollectionPreview({required this.collection, super.key});
  final Collection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItemsInCollection(
      id: collection.id!,
      limit: 4,
      buildOnData: (clMediaList) {
        final mediaWithPreview = clMediaList
            .where((e) => File(e.previewFileName).existsSync())
            .toList();
        print('${collection.label} ==> ${clMediaList.length} ');
        final (c, r) = switch (mediaWithPreview.length) {
          1 => (1, 1),
          2 => (2, 1),
          _ => (2, 2)
        };
        return Center(
          child: MediaPreview(
            media: mediaWithPreview,
            columns: c,
            rows: r,
          ),
        );
      },
    );
  }
}

class CLGridItemSquare extends StatelessWidget {
  const CLGridItemSquare({
    required this.backgroundColor,
    super.key,
    this.child,
  });

  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox.square(
        dimension: 128,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
