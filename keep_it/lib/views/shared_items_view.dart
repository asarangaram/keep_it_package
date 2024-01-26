import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/from_store/load_tags.dart';
import '../widgets/save_or_cancel.dart';
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
  late TextEditingController descriptionController;
  late FocusNode descriptionNode;
  bool isSaving = false;

  @override
  void initState() {
    descriptionController = TextEditingController();
    descriptionNode = FocusNode();
    if (descriptionNode.canRequestFocus) {
      descriptionNode.requestFocus();
    }
    descriptionController.selection = TextSelection.fromPosition(
      TextPosition(offset: descriptionController.text.length),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    descriptionNode.dispose();
    super.dispose();
  }

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
                        Expanded(
                          child: CLMediaGridViewFixed(
                            mediaList: media.list,
                            hCount: switch (media.list.length) {
                              < 2 => 1,
                              < 4 => 2,
                              _ => 3,
                            },
                          ),
                        ),
                        SizedBox(
                          height: kMinInteractiveDimension * 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CLTextField.multiLine(
                              descriptionController,
                              focusNode: descriptionNode,
                              label: 'What is the best thing,'
                                  ' you can say about this?',
                              hint: 'What is the best thing,'
                                  ' you can say about this?',
                              maxLines: 5,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: kMinInteractiveDimension * 3,
                          child: isSaving
                              ? const Center(
                                  child: CLLoadingView(
                                    message: 'Saving...',
                                  ),
                                )
                              : SaveOrCancel(
                                  saveLabel: 'Save into...',
                                  cancelLabel: 'Discard',
                                  onDiscard: () => widget.onDiscard(media),
                                  onSave: () => onSave(media),
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

  void onSave(CLMediaInfoGroup media) {
    FocusScope.of(context).unfocus();
    TagsDialog.selectTags(
      context,
      onSelectionDone: (
        List<Tag> selectedTags,
      ) async {
        setState(() {
          isSaving = true;
        });
        await onSelectionDone(
          media: media,
          descriptionText: descriptionController.text,
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

  Future<void> onSelectionDone({
    required List<int> saveIntoTagsId,
    required CLMediaInfoGroup media,
    required String descriptionText,
  }) async {
    _infoLogger('Start loading');
    final stopwatch = Stopwatch()..start();
    // No one might be reading this, read once
    ref.read(collectionsProvider(null));
    final collectionId =
        await ref.read(collectionsProvider(null).notifier).upsertCollection(
              Collection(description: descriptionText),
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
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
