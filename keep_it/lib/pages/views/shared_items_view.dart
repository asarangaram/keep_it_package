import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/load_from_store/load_from_store.dart';
import 'package:keep_it/pages/views/receive_shared/media_preview.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

import 'collections_page/keepit_dialogs.dart';
import 'receive_shared/save_or_cancel.dart';

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
      child: Stack(
        children: [
          LoadCollections(
            buildOnData: (collections) => widget.mediaAsync.when(
              data: (media) {
                return SafeArea(
                  child: SizedBox(
                    width: min(MediaQuery.of(context).size.width, 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: MediaPreview(
                            media: media.list,
                            columns: switch (media.list.length) {
                              < 2 => 1,
                              < 4 => 2,
                              _ => 3
                            },
                          ),
                        ),
                        SizedBox(
                          height: kMinInteractiveDimension * 5,
                          width: min(MediaQuery.of(context).size.width, 450),
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
                          height: kMinInteractiveDimension * 2,
                          width: min(MediaQuery.of(context).size.width, 450),
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
                    ) /*  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MediaPreview(
                            media: media.list,
                            columns: switch (media.list.length) {
                              < 2 => 1,
                              < 4 => 2,
                              _ => 3
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (!isSaving) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CLTextField.multiLine(
                              descriptionController,
                              focusNode: descriptionNode,
                              label: 'Tell Something',
                              hint: 'Tell Something',
                              maxLines: 5,
                            ),
                          ),
                          SaveOrCancel(
                            saveLabel: 'Save into...',
                            cancelLabel: 'Discard',
                            onDiscard: () => widget.onDiscard(media),
                            onSave: onSave,
                          ),
                        ],
                      ],
                    ), */
                    ,
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
    );
  }

  void onSave(CLMediaInfoGroup media) {
    FocusScope.of(context).unfocus();
    KeepItDialogs.selectCollections(
      context,
      onSelectionDone: (
        List<Collection> selectedCollections,
      ) async {
        setState(() {
          isSaving = true;
        });
        await onSelectionDone(
          media: media,
          descriptionText: descriptionController.text,
          saveIntoCollectionsId: selectedCollections
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
    required List<int> saveIntoCollectionsId,
    required CLMediaInfoGroup media,
    required String descriptionText,
  }) async {
    _infoLogger('Start loading');
    final stopwatch = Stopwatch()..start();
    // No one might be reading this, read once
    ref.read(clustersProvider(null));
    final clusterId =
        await ref.read(clustersProvider(null).notifier).upsertCluster(
              Cluster(description: descriptionText),
              saveIntoCollectionsId,
            );

    final items = <ItemInDB>[
      for (final entry in media.list)
        await entry.keepFile(clusterId: clusterId),
    ];

    ref.read(itemsProvider(clusterId));
    ref.read(itemsProvider(clusterId).notifier).upsertItems(items);
    stopwatch.stop();

    await ref.read(notificationMessageProvider.notifier).push('Saved.');

    _infoLogger(
      'Elapsed time: ${stopwatch.elapsedMilliseconds} milliseconds'
      ' [${stopwatch.elapsed}]',
    );
  }
}

extension ExtItemInDB on CLMedia {
  Future<ItemInDB> keepFile({
    required int clusterId,
  }) async {
    if (![CLMediaType.video, CLMediaType.image].contains(type)) {
      return ItemInDB(
        clusterId: clusterId,
        path: this.path,
        type: type,
      );
    }

    return ItemInDB(
      clusterId: clusterId,
      path:
          await (await copy(toDir: path.join('keep_it', 'cluster_$clusterId')))
              .relativePathFuture,
      type: type,
      ref: url,
    );
  }
}

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
