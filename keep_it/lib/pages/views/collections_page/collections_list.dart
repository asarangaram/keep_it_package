import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/pages/views/collections_page/collections_list_item.dart';
import 'package:store/store.dart';

class CollectionsList extends ConsumerWidget {
  const CollectionsList({
    required this.collectionList,
    super.key,
    this.onSelection,
    this.selectionMask,
  });

  final List<Collection> collectionList;
  final void Function(int index)? onSelection;
  final List<bool>? selectionMask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectionMask != null) {
      if (selectionMask!.length != collectionList.length) {
        throw Exception('Selection is setup incorrectly');
      }
    }
    if (collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    final random = Random(42);

    return SizedBox.expand(
      child: ListView.builder(
        itemCount: collectionList.length,
        itemBuilder: (context, index) {
          return CollectionsListItem(
            collectionList[index],
            isSelected: selectionMask?[index],
            random: random,
            onTap: (onSelection == null)
                ? () {
                    context.push(
                      '/clusters/by_collection_id/${collectionList[index].id}',
                    );
                  }
                : () => onSelection!.call(index),
          );
        },
      ),
    );
  }
}
