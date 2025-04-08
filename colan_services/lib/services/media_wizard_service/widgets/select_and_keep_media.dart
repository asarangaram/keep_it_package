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

  final List<GalleryGroupStoreEntity<ViewerEntityMixin>> galleryMap;

  @override
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);
  late StoreEntity? targetCollection;
  late bool actionConfirmed;

  @override
  void initState() {
    actionConfirmed = widget.type == UniversalMediaSource.move;
    targetCollection = widget.media.collection;

    super.initState();
  }

  Future<bool> actor({
    required List<StoreEntity> currMedia,
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
    required List<StoreEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return restore(
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
    required List<StoreEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          (await DialogService.restoreMediaMultiple(
            context,
            media: currMedia.map((e) => e.entity).toList(),
          )) ??
          false,
      action: () async {
        for (final item in currMedia) {
          await item.updateWith(isDeleted: () => false);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> permanentlyDelete({
    required List<StoreEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          await DialogService.permanentlyDeleteMediaMultiple(
            context,
            media: currMedia.map((e) => e.entity).toList(),
          ) ??
          false,
      action: () async {
        for (final item in currMedia) {
          await item.delete();
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> delete({
    required List<StoreEntity> currMedia,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return permanentlyDelete(
        currMedia: currMedia,
        onUpdateSelectionmode: onUpdateSelectionmode,
      );
    }
    return actor(
      currMedia: currMedia,
      confirmAction: () async =>
          await DialogService.deleteMultipleEntities(
            context,
            media: currMedia.map((e) => e.entity).toList(),
          ) ??
          false,
      action: () async {
        for (final item in currMedia) {
          await item.updateWith(isDeleted: () => true);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Widget getCollection({required List<StoreEntity> currMedia}) {
    return CreateCollectionWizard(
      isValidSuggestion: (collection) {
        return !collection.entity.isDeleted;
      },
      onDone: ({required collection}) => setState(() {
        targetCollection = collection;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onUpdateSelectionmode: onUpdateSelectionmode,
                      currMedia: currMedia,
                    ),
          ),
          freezeView: actionConfirmed,
          onSelectionChanged: (List<StoreEntity> items) {
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
                        onDone: () async {
                          await ref
                              .read(
                                universalMediaProvider(widget.type).notifier,
                              )
                              .remove(currMedia);
                          selectedMedia = const CLSharedMedia(entries: []);
                          actionConfirmed = false;
                          targetCollection = null;
                          onUpdateSelectionmode(enable: false);
                          setState(() {});

                          ref.read(reloadProvider.notifier).reload();
                        },
                      )
                : null
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
  final void Function(List<StoreEntity>)? onSelectionChanged;
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
    required this.onDone,
    super.key,
  });
  final List<StoreEntity> media2Move;
  final StoreEntity newParent;

  final Future<void> Function() onDone;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Progress>(
      stream: moveMultiple(
        items: media2Move,
        newParent: newParent,
        onDone: ({
          required List<StoreEntity> mediaMultiple,
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

  Stream<Progress> moveMultiple({
    required List<StoreEntity> items,
    required StoreEntity newParent,
    required Future<void> Function({
      required List<StoreEntity> mediaMultiple,
    }) onDone,
  }) async* {
    yield const Progress(fractCompleted: 0, currentItem: '');

    throw UnimplementedError();
  }
}
