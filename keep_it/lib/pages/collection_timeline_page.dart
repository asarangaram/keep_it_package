// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/timeline_view.dart';

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({required this.collectionId, super.key});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GetCollection(
        id: collectionId,
        buildOnData: (collection) => GetMediaByCollectionId(
          collectionId: collectionId,
          buildOnData: (items) => TimeLineView(
            label: collection?.label ?? 'All Media',
            items: items,
            tagPrefix: 'Gallery View Media CollectionId: ${collection?.id}',
            onPickFiles: () async => onPickFiles(
              context,
              ref,
              collection: collection,
            ),
          ),
        ),
      );
}
