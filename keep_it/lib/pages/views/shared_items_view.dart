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
import 'package:store/store.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({
    required this.media,
    required this.onDiscard,
    super.key,
  });

  final CLMediaInfoGroup media;
  final void Function() onDiscard;

  @override
  ConsumerState<SharedItemsView> createState() => _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  late TextEditingController descriptionController;

  @override
  void initState() {
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      child: LoadCollections(
        buildOnData: (collections) {
          return SafeArea(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  disabledBorder: CLTextField.buildOutlineInputBorder(context),
                  enabledBorder: CLTextField.buildOutlineInputBorder(context),
                  focusedBorder:
                      CLTextField.buildOutlineInputBorder(context, width: 2),
                  errorBorder: CLTextField.buildOutlineInputBorder(context),
                  focusedErrorBorder:
                      CLTextField.buildOutlineInputBorder(context, width: 2),
                  errorStyle: CLTextField.buildTextStyle(context),
                  floatingLabelStyle: CLTextField.buildTextStyle(context),
                ),
              ),
              child: SizedBox(
                width: min(MediaQuery.of(context).size.width, 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: MediaPreview(
                        media: widget.media.list,
                        showAll: true,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CLTextField.multiLine(
                        descriptionController,
                        label: 'Tell Something',
                        hint: 'Tell Something',
                        maxLines: 5,
                      ),
                    ),
                    SaveOrCancel(
                      saveLabel: 'Keep it',
                      cancelLabel: 'Discard',
                      onDiscard: widget.onDiscard,
                      onSave: () => KeepItDialogs.selectCollections(
                        context,
                        onSelectionDone:
                            (List<Collection> selectedCollections) async {
                          await onSelectionDone(
                            context,
                            ref,
                            selectedCollections,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> onSelectionDone(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collectionList,
  ) async {
    final ids =
        collectionList.where((c) => c.id != null).map((c) => c.id!).toList();

    // No one might be reading this, read once
    ref.read(clustersProvider(null));
    final clusterId = await ref
        .read(clustersProvider(null).notifier)
        .upsertCluster(Cluster(description: descriptionController.text), ids);
    debugPrint('Items in Cluster ${widget.media.list.length}');
    final items = <ItemInDB>[];
    for (final entry in widget.media.list) {
      switch (entry.type) {
        case CLMediaType.image:
        case CLMediaType.video:
          // Copy item to storage.
          final newFile = await FileHandler.move(entry.path, toDir: 'keepIt');
          // if URL is stored, read it and delete
          final logFileName = '${entry.path}.url';
          String? imageUrl;
          if (File(logFileName).existsSync()) {
            imageUrl = await File(logFileName).readAsString();
            await File(logFileName).delete();
          }
          if (entry.type == CLMediaType.video) {
            await VideoHandler.generateVideoThumbnail(newFile);
          }
          final item = ItemInDB(
            type: entry.type,
            path: newFile.replaceAll(
              '${await FileHandler.getDocumentsDirectory(null)}/',
              '',
            ),
            ref: imageUrl?.replaceAll(
              '${await FileHandler.getDocumentsDirectory(null)}/',
              '',
            ),
            clusterId: clusterId,
          );
          // Create thumbnail

          items.add(item);

        case CLMediaType.text:
        case CLMediaType.url:
        case CLMediaType.audio:
        case CLMediaType.file:
          throw UnimplementedError();
      }
    }
    ref.read(itemsProvider(clusterId));
    ref.read(itemsProvider(clusterId).notifier).upsertItems(items);
  }
}
