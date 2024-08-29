import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:store/store.dart';

extension UpsertMultipleOnStoreManager on StoreManager {
  //Can be converted to non static
  Stream<Progress> moveToCollectionStream(
    List<CLMedia> mediaMultiple, {
    required Collection collection,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await store.upsertCollection(collection);
    } else {
      updatedCollection = collection;
    }

    if (mediaMultiple.isNotEmpty) {
      final streamController = StreamController<Progress>();

      unawaited(
        upsertMediaMultiple(
          mediaMultiple
              .map(
                (e) => e.copyWith(
                  isHidden: false,
                  collectionId: updatedCollection.id,
                ),
              )
              .toList(),
          onProgress: (progress) async {
            streamController.add(progress);
            await Future<void>.delayed(const Duration(microseconds: 1));
          },
        ).then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 1));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }

  Future<void> upsertMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    for (final (i, m) in mediaMultiple.indexed) {
      await store.upsertMedia(m);
      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.name,
        ),
      );
    }
  }
}
