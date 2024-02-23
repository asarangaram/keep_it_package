import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'pick_collection.dart';

class KeepMediaWizard extends ConsumerWidget {
  const KeepMediaWizard({
    required this.media,
    required this.onDiscard,
    required this.onAccept,
    super.key,
  });
  final CLMediaList media;

  final void Function() onDiscard;
  final void Function({
    CLMediaList? mg,
  }) onAccept;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadCollections(
      buildOnData: (collections) {
        return PickCollection(
          suggestedCollections: collections.entries,
          preSelectedCollection: media.collectionId == null
              ? null
              : collections.entries
                  .where((element) => element.id == media.collectionId)
                  .firstOrNull,
          onDone: ({
            required Collection collection,
            List<Tag>? selectedTags,
          }) async {
            await onSelectionDone(
              ref: ref,
              media: media,
              collection: collection,
              saveIntoTagsId: selectedTags?.map((e) => e.id!).toList(),
            );
          },
        );
      },
    );
  }

  Future<void> onSelectionDone({
    required WidgetRef ref,
    required CLMediaList media,
    required Collection collection,
    List<int>? saveIntoTagsId,
  }) async {
    // No one might be reading this, read once
    ref.read(collectionsProvider(null));
    final collectionId =
        await ref.read(collectionsProvider(null).notifier).upsertCollection(
              collection,
              saveIntoTagsId,
            );
    final items =
        media.entries.map((e) => e.setCollectionId(collectionId)).toList();
    onAccept(
      mg: CLMediaList(entries: items, collectionId: collectionId),
    );
  }

  static Future<void> onUpdateDB(
    BuildContext context,
    WidgetRef ref,
    CLMediaList updatedMedia,
  ) async {
    ref.read(clMediaListByCollectionIdProvider(updatedMedia.collectionId!));
    await ref
        .read(
          clMediaListByCollectionIdProvider(updatedMedia.collectionId!)
              .notifier,
        )
        .upsertItems(updatedMedia.entries);
    await ref.read(notificationMessageProvider.notifier).push('Saved.');
  }
}
