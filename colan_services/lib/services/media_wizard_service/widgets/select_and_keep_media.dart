import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/builders/get_selection_mode.dart';
import '../../../internal/entity_grid/widgets/selection_control/selection_control.dart';
import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../context_menu_service/models/wizard_menu_items.dart';
import 'create_collection_wizard.dart';
import 'wizard_preview.dart';

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
    required this.viewIdentifier,
    required this.media,
    required this.type,
    required this.galleryMap,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;
  final ViewIdentifier viewIdentifier;

  final List<GalleryGroupCLEntity<CLEntity>> galleryMap;

  @override
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);
  late CLEntity? targetCollection;
  late bool actionConfirmed;

  @override
  void initState() {
    actionConfirmed = widget.type == UniversalMediaSource.move;
    targetCollection = widget.media.collection;

    super.initState();
  }

  Future<bool> actor({
    required List<CLEntity> currMedia,
    required Future<bool> Function() confirmAction,
    required Future<bool> Function() action,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    actionConfirmed = true;
    setState(() {});
    final bool res;
    if (await confirmAction()) {
      if (await action()) {
        selectedMedia = const CLSharedMedia(entries: []);
        await ref
            .read(
              universalMediaProvider(widget.type).notifier,
            )
            .remove(currMedia);
        onUpdateSelectionmode(enable: false);
        setState(() {});
        res = true;
      } else {
        throw Exception('Action failed');
      }
    } else {
      res = false;
    }
    actionConfirmed = false;
    setState(() {});
    return res;
  }

  Future<bool> keep({
    required MediaUpdater mediaUpdater,
    required List<CLEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return restore(
        mediaUpdater: mediaUpdater,
        currMedia: currMedia,
        onUpdateSelectionmode: onUpdateSelectionmode,
      );
    }
    //targetCollection = widget.media.collection;
    actionConfirmed = true;
    setState(() {});
    onUpdateSelectionmode(enable: false);
    return true;
  }

  Future<bool> restore({
    required MediaUpdater mediaUpdater,
    required List<CLEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          (await DialogService.restoreMediaMultiple(
            context,
            media: currMedia,
          )) ??
          false,
      action: () => mediaUpdater.restoreMultiple(
        currMedia.map((e) => e.id!).toSet(),
      ),
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> permanentlyDelete({
    required MediaUpdater mediaUpdater,
    required List<CLEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          await DialogService.permanentlyDeleteMediaMultiple(
            context,
            media: currMedia,
          ) ??
          false,
      action: () async => mediaUpdater.deletePermanentlyMultiple(
        currMedia.map((e) => e.id!).toSet(),
      ),
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> delete({
    required MediaUpdater mediaUpdater,
    required List<CLEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return permanentlyDelete(
        currMedia: currMedia,
        mediaUpdater: mediaUpdater,
        onUpdateSelectionmode: onUpdateSelectionmode,
      );
    }
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          await DialogService.deleteMultipleEntities(
            context,
            media: currMedia,
          ) ??
          false,
      action: () async => mediaUpdater.deleteMultiple(
        {...currMedia.map((e) => e.id!)},
      ),
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Widget getCollection({required List<CLEntity> currMedia}) {
    return CreateCollectionWizard(
      isValidSuggestion: (collection) {
        return !collection.isDeleted;
      },
      onDone: ({required collection}) => setState(() {
        targetCollection = collection;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetStoreUpdater(
      errorBuilder: (_, __) => throw UnimplementedError('errorBuilder'),
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return GetSelectionMode(
          viewIdentifier: widget.viewIdentifier,
          builder: ({
            required onUpdateSelectionmode,
            required selectionMode,
            required tabIdentifier,
          }) {
            final currMedia =
                (selectionMode ? selectedMedia.entries : widget.media.entries);
            return WizardView(
              viewIdentifier: widget.viewIdentifier,
              canSelect: !actionConfirmed && widget.media.entries.length > 1,
              menu: WizardMenuItems.moveOrCancel(
                type: widget.type,
                keepActionLabel: [
                  widget.type.keepActionLabel,
                  if (selectionMode)
                    'Selected'
                  else
                    widget.media.entries.length > 1 ? 'All' : '',
                ].join(' '),
                keepAction: currMedia.isEmpty
                    ? null
                    : () => keep(
                          mediaUpdater: theStore.mediaUpdater,
                          onUpdateSelectionmode: onUpdateSelectionmode,
                          currMedia: currMedia,
                        ),
                deleteActionLabel: [
                  widget.type.deleteActionLabel,
                  if (selectionMode)
                    'Selected'
                  else
                    widget.media.entries.length > 1 ? 'All' : '',
                ].join(' '),
                deleteAction: currMedia.isEmpty
                    ? null
                    : () => delete(
                          mediaUpdater: theStore.mediaUpdater,
                          onUpdateSelectionmode: onUpdateSelectionmode,
                          currMedia: currMedia,
                        ),
              ),
              freezeView: actionConfirmed,
              onSelectionChanged: (List<CLEntity> items) {
                selectedMedia = selectedMedia.copyWith(entries: items);
                setState(() {});
              },
              dialog: switch (widget.type) {
                UniversalMediaSource.deleted => null,
                _ => actionConfirmed
                    ? (targetCollection == null)
                        ? getCollection(
                            currMedia: currMedia,
                          )
                        : KeepWithProgress(
                            media2Move: currMedia,
                            newParent: targetCollection!,
                            mediaUpdater: theStore.mediaUpdater,
                            onDone: () async {
                              await ref
                                  .read(
                                    universalMediaProvider(widget.type)
                                        .notifier,
                                  )
                                  .remove(currMedia);
                              selectedMedia = const CLSharedMedia(entries: []);
                              actionConfirmed = false;
                              targetCollection = null;
                              onUpdateSelectionmode(enable: false);
                              setState(() {});

                              theStore.store.reloadStore();
                            },
                          )
                    : null
              },
            );
          },
        );
      },
    );
  }
}

class WizardView extends ConsumerWidget {
  const WizardView({
    required this.viewIdentifier,
    required this.menu,
    required this.freezeView,
    required this.canSelect,
    required this.onSelectionChanged,
    required this.dialog,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final WizardMenuItems menu;
  final bool canSelect;
  final Widget? dialog;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool freezeView; // Can this avoided?

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WizardLayout(
      title: menu.type.label,
      onCancel: () => PageManager.of(context).pop(),
      actions: [
        if (canSelect)
          // FIX ME: select ICon or text?
          SelectionControlIcon(
            viewIdentifier: viewIdentifier,
          ),
      ],
      wizard: dialog ??
          WizardDialog(
            option1: menu.option1,
            option2: menu.option2,
          ),
      child: WizardPreview(
        viewIdentifier: viewIdentifier,
        type: menu.type,
        onSelectionChanged: onSelectionChanged,
        freezeView: freezeView,
      ),
    );
  }
}

class KeepWithProgress extends StatelessWidget {
  const KeepWithProgress({
    required this.media2Move,
    required this.newParent,
    required this.mediaUpdater,
    required this.onDone,
    super.key,
  });
  final List<CLEntity> media2Move;
  final CLEntity newParent;
  final MediaUpdater mediaUpdater;

  final Future<void> Function() onDone;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Progress>(
      stream: mediaUpdater.moveMultiple(
        media: media2Move,
        collection: newParent,
        shouldRefresh: false,
        onDone: ({
          required List<CLEntity> mediaMultiple,
        }) async =>
            onDone(),
      ),
      builder: (context, snapShot) {
        return ProgressBar(
          progress: snapShot.hasData ? snapShot.data?.fractCompleted : null,
        );
      },
    );
  }
}
