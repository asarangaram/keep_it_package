import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/from_store/load_collections.dart';
import '../widgets/from_store/load_tags.dart';
import '../widgets/new_collection_form.dart';
import '../widgets/tags_dialogs.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({
    required this.mediaAsync,
    required this.onDiscard,
    super.key,
  });

  final AsyncValue<CLMediaInfoGroup> mediaAsync;
  final void Function(CLMediaInfoGroup media) onDiscard;

  @override
  ConsumerState<SharedItemsView> createState() => _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      child: CLBackground(
        child: Stack(
          children: [
            LoadTags(
              buildOnData: (tags) => widget.mediaAsync.when(
                data: (media) {
                  return SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: CLMediaGridViewFixed(
                            mediaList: media.list,
                            hCount: switch (media.list.length) {
                              < 2 => 1,
                              < 4 => 2,
                              _ => 3,
                            },
                          ),
                        ),
                        const Divider(
                          thickness: 4,
                        ),
                        SizedBox(
                          height: kMinInteractiveDimension * 4,
                          child: LoadCollections(
                            buildOnData: (collections) {
                              return PickCollectionBase(
                                suggestedCollections: collections.entries,
                                onDone: (c) {
                                  onSave(
                                    media: media,
                                    collection: Collection.fromBase(c),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (err, _) => CLErrorView(errorMessage: err.toString()),
                loading: () => const Center(
                  child: CLLoadingView(message: 'Looking for Shared Content'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSave({
    required CLMediaInfoGroup media,
    required Collection collection,
  }) async {
    if (collection.id != null) {
      // Existing id, no need to select Tags
      await onSelectionDone(media: media, collection: collection);
      widget.onDiscard(media);
    } else {
      FocusScope.of(context).unfocus();
      await TagsDialog.selectTags(
        context,
        onSelectionDone: (
          List<Tag> selectedTags,
        ) async {
          await onSelectionDone(
            media: media,
            collection: collection,
            saveIntoTagsId: selectedTags
                .where((c) => c.id != null)
                .map((c) => c.id!)
                .toList(),
          );

          widget.onDiscard(media);
        },
        labelNoneSelected: 'Select Tags',
        labelSelected: 'Save',
      );
    }
  }

  Future<void> onSelectionDone({
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

    final items = <ItemInDB>[
      for (final entry in media.list)
        await ExtItemInDB.fromCLMedia(entry, collectionId: collectionId),
    ];

    ref.read(itemsProvider(collectionId));
    ref.read(itemsProvider(collectionId).notifier).upsertItems(items);
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
