import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../from_store/load_collections.dart';
import 'pick_collection.dart';

class KeepMediaWizard extends ConsumerWidget {
  const KeepMediaWizard({
    required this.media,
    required this.onDiscard,
    required this.onAccept,
    super.key,
  });
  final CLMediaInfoGroup media;

  final void Function() onDiscard;
  final void Function(
    CLMediaInfoGroup media, {
    required Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      CLMediaInfoGroup media,
    ) onUpdateDB,
  }) onAccept;
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
    // No one might be reading this, read once
    ref.read(collectionsProvider(null));
    final collectionId =
        await ref.read(collectionsProvider(null).notifier).upsertCollection(
              collection,
              saveIntoTagsId,
            );
    onAccept(
      media.copyWith(targetID: collectionId),
      onUpdateDB: onUpdateDB,
    );
  }

  static Future<void> onUpdateDB(
    BuildContext context,
    WidgetRef ref,
    CLMediaInfoGroup updatedMedia,
  ) async {
    ref.read(itemsProvider(updatedMedia.targetID!));
    await ref
        .read(itemsProvider(updatedMedia.targetID!).notifier)
        .upsertItems(updatedMedia.list);
    await ref.read(notificationMessageProvider.notifier).push('Saved.');
  }
}
