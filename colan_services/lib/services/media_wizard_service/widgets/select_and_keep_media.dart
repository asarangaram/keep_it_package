import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'create_collection_wizard.dart';
import 'wizard_menu_items.dart';
import 'wizard_preview.dart';

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
    required this.viewIdentifier,
    required this.media,
    required this.type,
    required this.storeIdentity,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;

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
    required List<StoreEntity> currEntities,
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
            .remove(currEntities);
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
    required List<StoreEntity> currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return restore(
        currEntities: currEntities,
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
    required List<StoreEntity> currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currEntities: currEntities,
      confirmAction: () async =>
          (await DialogService.restoreMediaMultiple(
            context,
            media: currEntities,
          )) ??
          false,
      action: () async {
        for (final item in currEntities) {
          await item.updateWith(isDeleted: () => false);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> permanentlyDelete({
    required List<StoreEntity> currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    return actor(
      currEntities: currEntities,
      confirmAction: () async =>
          await DialogService.permanentlyDeleteMediaMultiple(
            context,
            media: currEntities,
          ) ??
          false,
      action: () async {
        for (final item in currEntities) {
          await item.delete();
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> delete({
    required List<StoreEntity> currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == UniversalMediaSource.deleted) {
      return permanentlyDelete(
        currEntities: currEntities,
        onUpdateSelectionmode: onUpdateSelectionmode,
      );
    }
    return actor(
      currEntities: currEntities,
      confirmAction: () async =>
          await DialogService.deleteMultipleEntities(
            context,
            media: currEntities,
          ) ??
          false,
      action: () async {
        for (final item in currEntities) {
          await item.updateWith(isDeleted: () => true);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Widget getCollection({required List<StoreEntity> currEntities}) {
    return CreateCollectionWizard(
      storeIdentity: widget.storeIdentity,
      isValidSuggestion: (collection) {
        return !collection.data.isDeleted;
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
        required viewIdentifier,
      }) {
        final currEntities =
            (selectionMode ? selectedMedia.entries : widget.media.entries);
        return WizardView(
          viewIdentifier: widget.viewIdentifier,
          storeIdentity: widget.storeIdentity,
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
            keepAction: currEntities.isEmpty
                ? null
                : () => keep(
                      onUpdateSelectionmode: onUpdateSelectionmode,
                      currEntities: currEntities,
                    ),
            deleteActionLabel: [
              widget.type.deleteActionLabel,
              if (selectionMode)
                'Selected'
              else
                widget.media.entries.length > 1 ? 'All' : '',
            ].join(' '),
            deleteAction: currEntities.isEmpty
                ? null
                : () => delete(
                      onUpdateSelectionmode: onUpdateSelectionmode,
                      currEntities: currEntities,
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
                        currEntities: currEntities,
                      )
                    : KeepWithProgress(
                        media2Move: currEntities,
                        newParent: targetCollection!,
                        onDone: () async {
                          await ref
                              .read(
                                universalMediaProvider(widget.type).notifier,
                              )
                              .remove(currEntities);
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
    required this.storeIdentity,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final WizardMenuItems menu;
  final bool canSelect;
  final Widget? dialog;
  final void Function(List<StoreEntity>)? onSelectionChanged;
  final bool freezeView; // Can this avoided?
  final String storeIdentity;

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
        storeIdentity: storeIdentity,
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
    final parentCollection = await newParent.dbSave();
    if (parentCollection == null || parentCollection.id == null) {
      throw Exception('failed to save parent collection');
    }

    final updatedItems = <StoreEntity>[];
    for (final (i, item) in items.indexed) {
      yield Progress(fractCompleted: (i + 1) / items.length, currentItem: '');
      final updated = await (await item.updateWith(
        parentId: () => parentCollection.id!,
        isHidden: () => false,
      ))
          ?.dbSave();
      if (updated == null) {
        throw Exception('Failed to update item ${item.id}');
      }
      updatedItems.add(updated);
    }
    yield const Progress(fractCompleted: 1, currentItem: 'All items are moved');
    await onDone(mediaMultiple: updatedItems);
  }
}

class SelectionControlIcon extends ConsumerWidget {
  const SelectionControlIcon({required this.viewIdentifier, super.key});

  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetSelectionMode(
      viewIdentifier: viewIdentifier,
      builder: ({
        required void Function({required bool enable}) onUpdateSelectionmode,
        required bool selectionMode,
        required ViewIdentifier viewIdentifier,
      }) {
        return ShadButton.ghost(
          padding: const EdgeInsets.only(right: 8),
          onPressed: () {
            onUpdateSelectionmode(enable: !selectionMode);
          },
          child: const Icon(LucideIcons.listChecks),
        );
      },
    );
  }
}
