import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  bool haveLabel = false;
  bool editLabel = false;

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
                        const Divider(
                          thickness: 2,
                        ),
                        if (haveLabel)
                          if (editLabel)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextField(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: kMinInteractiveDimension * 3,
                                    child: Align(
                                      child: CLButtonIcon.large(
                                        Icons.check,
                                        onTap: () {
                                          setState(() {
                                            editLabel = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: editLabel
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                Text(
                                  'This is your label',
                                  style: TextStyle(
                                    fontSize: CLScaleType.large.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                CLButtonIcon.large(
                                  Icons.edit,
                                  onTap: () {
                                    setState(() {
                                      editLabel = !editLabel;
                                    });
                                  },
                                ),
                              ],
                            ),
                        SizedBox(
                          height: kMinInteractiveDimension * 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(),
                                          left: BorderSide(),
                                          bottom: BorderSide(),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    width: kMinInteractiveDimension * 3,
                                    child: Center(
                                      child: CLButtonIconLabelled.large(
                                        MdiIcons.arrowRight,
                                        haveLabel ? 'Select Tags' : 'Next',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        onTap: () {
                                          if (!haveLabel) {
                                            setState(() {
                                              haveLabel = true;
                                            });
                                          } else {
                                            onSave(media);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /* Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: CLTextField.multiLine(
                              descriptionController,
                              focusNode: descriptionNode,
                              hint: 'Write here...',
                              label: 'What is the best thing,'
                                  ' you can say about this?',
                              maxLines: 5,
                              suffix: Container(
                                height: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ), // Adjust the padding as needed

                                color:
                                    Colors.yellow, // Set the background color
                                child: CLButtonIconLabelled.large(
                                  MdiIcons.arrowRight,
                                  'Next',
                                ),
                              ),
                            ),
                          ) */
                        ),
                        SizedBox(
                          height: kMinInteractiveDimension * 2,
                          child: isSaving
                              ? const Center(
                                  child: CLLoadingView(
                                    message: 'Saving...',
                                  ),
                                )
                              : SaveOrCancel(
                                  canSave: false,
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
