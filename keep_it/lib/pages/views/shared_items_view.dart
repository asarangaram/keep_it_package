import 'dart:io';
import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/keepit_dialogs.dart';
import 'package:store/store.dart';

import 'load_from_store/load_collections.dart';
import 'receive_shared/media_preview.dart';
import 'receive_shared/save_or_cancel.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({
    super.key,
    required this.media,
    required this.onDiscard,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;

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
      useSafeArea: false,
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
              )),
              child: SizedBox(
                width: min(MediaQuery.of(context).size.width, 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: MediaPreview(media: widget.media)),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CLTextField.multiLine(
                        descriptionController,
                        label: "Tell Something",
                        hint: "Tell Something",
                        maxLines: 5,
                      ),
                    ),
                    SaveOrCancel(
                      saveLabel: "Keep it",
                      cancelLabel: "Discard",
                      onDiscard: widget.onDiscard,
                      onSave: () => KeepItDialogs.selectCollections(
                        context,
                        onSelectionDone:
                            (List<Collection> selectedCollections) async {
                          await onSelectionDone(
                              context, ref, selectedCollections);
                          if (context.mounted) {
                            CLButtonsGrid.showSnackBarAboveDialog(
                                context, "Item(s) Saved",
                                onSnackBarRemoved: widget.onDiscard);
                          }

                          // onDiscard();
                        },
                        labelNoneSelected: "Select Tags",
                        labelSelected: "Save",
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

  onSelectionDone(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collectionList,
  ) async {
    List<int> ids =
        (collectionList).where((c) => c.id != null).map((c) => c.id!).toList();

    // No one might be reading this, read once
    ref.read(clustersProvider(null));
    final clusterId = await ref
        .read(clustersProvider(null).notifier)
        .upsertCluster(Cluster(description: descriptionController.text), ids);

    for (var entry in widget.media.entries) {
      switch (entry.value) {
        case SupportedMediaType.image:
        case SupportedMediaType.video:
          // Copy item to storage.
          final newFile = await FileHandler.move(entry.key, toDir: "keepIt");
          // if URL is stored, read it and delete
          final logFileName = '${entry.key}.url';
          String? imageUrl;
          if (File(logFileName).existsSync()) {
            imageUrl = await File(logFileName).readAsString();
            File(logFileName).delete();
          }
          final item = ItemInDB(
            type: entry.value,
            path: newFile.replaceAll(
                "${await FileHandler.getDocumentsDirectory(null)}/", ""),
            ref: imageUrl?.replaceAll(
                "${await FileHandler.getDocumentsDirectory(null)}/", ""),
            clusterId: clusterId,
          );
          ref.read(itemsProvider(clusterId));
          ref.read(itemsProvider(clusterId).notifier).upsertItem(item);

        default:
          throw UnimplementedError();
      }
    }
  }
}
