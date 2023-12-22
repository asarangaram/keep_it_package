import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collections_list_item.dart';

class CollectionsList extends ConsumerWidget {
  const CollectionsList({
    super.key,
    required this.collectionList,
    this.onSelection,
    this.selectionMask,
  });

  final List<Collection> collectionList;
  final Function(int index)? onSelection;
  final List<bool>? selectionMask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectionMask != null) {
      if (selectionMask!.length != collectionList.length) {
        throw Exception("Selection is setup incorrectly");
      }
    }
    if (collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    Random random = Random(42);

    return ListView.builder(
      itemCount: collectionList.length,
      itemBuilder: (context, index) {
        return CollectionsListItem(
          collectionList[index],
          isSelected: selectionMask?[index],
          random: random,
          onTap: (onSelection == null) ? null : () => onSelection!.call(index),
        );
      },
    );
  }
}
