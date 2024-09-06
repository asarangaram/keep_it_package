import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../media_view_service/widgets/media_view.dart';

import '../store_service/widgets/builders.dart';
import 'widgets/cl_media_collage.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView.preview(this.collection, {super.key});
  final Collection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    return CLAspectRationDecorated(
      hasBorder: true,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: GetStore(
        builder: (theStore) {
          final mediaList = theStore.getMediaByCollectionId(
            collection.id,
            maxCount: 4,
            isRandom: true,
          );

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
            return CLMediaCollage.byMatrixSize(
              mediaList.length,
              hCount: 2,
              vCount: 2,
              itemBuilder: (context, index) => MediaView.preview(
                mediaList[index],
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
