import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/keepit_dialogs.dart';
import 'package:keep_it/pages/views/load_from_store/load_from_store.dart';
import 'package:keep_it/pages/views/main/background.dart';
import 'package:keep_it/pages/views/receive_shared/media_preview.dart';
import 'package:keep_it/pages/views/receive_shared/save_or_cancel.dart';
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

  Future<void> onSelectionDone(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collectionList,
  ) async {}
}
