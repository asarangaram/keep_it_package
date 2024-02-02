import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../from_store/from_store.dart';
import 'pick_collection.dart';

class KeepMediaWizard extends ConsumerWidget {
  const KeepMediaWizard({
    required this.media,
    required this.onDone,
    super.key,
  });
  final CLMediaInfoGroup media;

  final void Function(CLMediaInfoGroup media) onDone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return LoadCollections(
      buildOnData: (collections) {
        return PickCollectionBase(
          suggestedCollections: collections.entries,
          preSelectedCollection: media.targetID == null
              ? null
              : collections.entries
                  .where((element) => element.id == media.targetID)
                  .firstOrNull,
          onDone: ({
            required CollectionBase collection,
            List<CollectionBase>? selectedTags,
          }) async {
            await onSelectionDone(
              ref: ref,
              media: media,
              collection: Collection.fromBase(collection),
              saveIntoTagsId: selectedTags?.map((e) => e.id!).toList(),
            );
            onDone(media);
          },
        );
      },
    );
  }

  Future<void> onSelectionDone({
    required WidgetRef ref,
    required CLMediaInfoGroup media,
    required Collection collection,
    List<int>? saveIntoTagsId,
  }) async {
    _infoLogger('Start loading');
    final stopwatch = Stopwatch()..start();
    // No one might be reading this, read once
    ref.read(collectionsProvider(null));
    final collectionId =
        await ref.read(collectionsProvider(null).notifier).upsertCollection(
              collection,
              saveIntoTagsId,
            );

    final items = <CLMedia>[
      for (final entry in media.list)
        entry.copyWith(collectionId: collectionId),
    ];

    ref.read(itemsProvider(collectionId));
    await ref.read(itemsProvider(collectionId).notifier).upsertItems(items);
    stopwatch.stop();

    await ref.read(notificationMessageProvider.notifier).push('Saved.');

    _infoLogger(
      'Elapsed time: ${stopwatch.elapsedMilliseconds} milliseconds'
      ' [${stopwatch.elapsed}]',
    );
  }
}

bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
