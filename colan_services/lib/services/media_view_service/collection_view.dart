import 'dart:io';
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../media_view_service/widgets/media_view.dart';
import '../store_service/widgets/get_store.dart';
import '../store_service/widgets/w3_get_media.dart';
import 'widgets/cl_media_collage.dart';

extension RandomExt<T> on List<T> {
  List<T> pickRandomItems(int count) {
    final copyList = List<T>.from(this); // Create a copy of the original list
    if (copyList.length <= count) {
      return copyList; // Return the entire list if it's shorter than 'count'
    }

    copyList.shuffle(Random()); // Shuffle the copy list
    return copyList.take(count).toList();
  }
}

class CollectionView extends ConsumerWidget {
  const CollectionView.preview(this.collection, {super.key});
  final Collection collection;

  List<T> pickRandomItems<T>(List<T> list, int count) {
    if (list.length <= count) {
      return List.from(
        list,
      ); // Return the entire list if it's shorter than 'count'
    }

    list.shuffle(Random()); // Shuffle the list using a random instance
    return list.sublist(
      0,
      count,
    ); // Take the first 'count' items from the shuffled list
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    return CLAspectRationDecorated(
      hasBorder: true,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: GetStoreManager(
        builder: (theStore) {
          return GetMediaByCollectionId(
            collectionId: collection.id,
            buildOnData: (mediaList) {
              if (mediaList.isEmpty) {
                return CLAspectRationDecorated(
                  hasBorder: true,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Center(
                    child: CLText.veryLarge(
                      collection.label.characters.first,
                    ),
                  ),
                );
              } else {
                final availableList = mediaList
                    .where(
                      (e) =>
                          File(theStore.getPreviewAbsolutePath(e)).existsSync(),
                    )
                    .toList()
                    .pickRandomItems(4);
                return CLMediaCollage.byMatrixSize(
                  availableList.length,
                  hCount: 2,
                  vCount: 2,
                  itemBuilder: (context, index) => MediaView.preview(
                    availableList[index],
                    parentIdentifier: 'TODO HERE',
                  ),
                  whenNopreview: Center(
                    child: CLText.veryLarge(
                      collection.label.characters.first,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

/* 


          class CollectionPreviewGenerator extends StatelessWidget {
  const CollectionPreviewGenerator({
    required this.collection,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context) {
    return GetMediaByCollectionId(
      collectionId: collection.id,
      buildOnData: (items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CollectionView.preview(collection),
        );
      },
    );
  }
}

*/
