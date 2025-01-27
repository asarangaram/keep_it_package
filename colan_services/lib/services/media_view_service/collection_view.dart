import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView.preview(this.collection, {super.key});
  final Collection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MediaQuery.of(context);
    final borderColor = collection.hasServerUID
        ? collection.haveItOffline
            ? Colors.blue
            : Colors.green
        : null;
    return CLAspectRationDecorated(
      hasBorder: true,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderColor: borderColor,
      child: Center(
        child: CLText.veryLarge(
          collection.label.characters.first,
        ),
      ),
    );
    /* 
    return GetMediaByCollectionId(
      collectionId: collection.id,
      errorBuilder: null,
      loadingBuilder: null,
      builder: (mediaList) {
        final borderColor = collection.hasServerUID
            ? collection.haveItOffline
                ? Colors.blue
                : Colors.green
            : null;
        if (mediaList.isEmpty || true) {
          return Badge.count(
            count: mediaList.entries.length,
            child: CLAspectRationDecorated(
            hasBorder: true,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            borderColor: borderColor,
            child: Center(
              child: CLText.veryLarge(
                collection.label.characters.first,
                ),
              ),
            ),
          );
          
        } else {
          return CLAspectRationDecorated(
            hasBorder: true,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            borderColor: borderColor,
            child: CLMediaCollage.byMatrixSize(
              mediaList.entries.length,
              hCount: 2,
              vCount: 2,
              itemBuilder: (context, index) => MediaView.preview(
                mediaList.entries[index],
                parentIdentifier: 'TODO HERE',
              ),
              whenNopreview: Center(
                child: CLText.veryLarge(
                  collection.label.characters.first,
                ),
              ),
            ),
          );
        }
      },
    );*/
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
