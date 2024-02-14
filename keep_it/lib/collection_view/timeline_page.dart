// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import 'empty_state.dart';
import 'group_view.dart';

class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionID, super.key});
  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadItems(
        collectionID: collectionID,
        buildOnData: (items) {
          return TimeLineView(
            Items(entries: items.images, collection: items.collection),
          );
        },
      );
}

class TimeLineView extends ConsumerWidget {
  const TimeLineView(this.items, {super.key});
  final Items items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GroupView(
      collection: items.collection,
      itemsMap: items.filterByDate(),
      emptyState: const EmptyState(),
      tagPrefix: 'timeline ${items.collection.id}',
    );
  }
}
