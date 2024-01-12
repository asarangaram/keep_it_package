import 'dart:io';
import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/keepit_dialogs.dart';
import 'package:keep_it/pages/views/load_from_store/load_from_store.dart';
import 'package:keep_it/pages/views/receive_shared/media_preview.dart';
import 'package:keep_it/pages/views/receive_shared/save_or_cancel.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({
    required this.mediaAsync,
    required this.onDiscard,
    super.key,
  });

  final AsyncValue<CLMediaInfoGroup> mediaAsync;
  final void Function() onDiscard;

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: MediaPreview(
                            media: media.list,
                            showAll: true,
                            maxCrossAxisCount: switch (media.list.length) {
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
                            onDiscard: widget.onDiscard,
                            onSave: () {
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
                                  if (context.mounted) {
                                    CLButtonsGrid.showSnackBarAboveDialog(
                                      context,
                                      'Item(s) Saved',
                                      onSnackBarRemoved: widget.onDiscard,
                                    );
                                  }

                                  // onDiscard();
                                },
                                labelNoneSelected: 'Select Tags',
                                labelSelected: 'Save',
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              error: (err, _) => CLErrorView(errorMessage: err.toString()),
              loading: () =>
                  const CLLoadingView(message: 'Looking for Shared Content'),
            ),
          ),
          if (isSaving)
            const Center(
              child: CLLoadingView(
                message: 'Saving...',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> onSelectionDone({
    required List<int> saveIntoCollectionsId,
    required CLMediaInfoGroup media,
    required String descriptionText,
  }) async {
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
    print(items);
    ref.read(itemsProvider(clusterId));
    ref.read(itemsProvider(clusterId).notifier).upsertItems(items);
  }
}

extension ExtItemInDB on CLMedia {
  Future<ItemInDB> keepFile({
    required int clusterId,
  }) async {
    if ([CLMediaType.text, CLMediaType.url].contains(type)) {
      return ItemInDB(
        clusterId: clusterId,
        path: this.path,
        type: type,
      );
    }
    final newFile = await FileHandler.move(
      this.path,
      toDir: path.join('keep_it', 'cluster_$clusterId'),
    );
    // Log File
    final logFileName = '${this.path}.url';
    String? imageUrl;
    if (File(logFileName).existsSync()) {
      imageUrl = File(logFileName).readAsStringSync();
      await File(logFileName).delete();
    }

    // Create Thumbnail
    if (type == CLMediaType.video) {
      await VideoHandler.generateVideoThumbnail(newFile);
    }

    return ItemInDB(
      clusterId: clusterId,
      path: await FileHandler.relativePath(newFile),
      type: type,
      ref: imageUrl,
    );
  }
}
