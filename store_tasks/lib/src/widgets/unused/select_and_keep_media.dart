/* import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/cl_shared_media.dart';
import '../models/content_origin.dart';
import '../providers/universal_media.dart';
import 'create_collection_wizard.dart';
import 'dialogs.dart';
import 'wizard_menu_items.dart';
import 'wizard_preview.dart';

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia(
      {required this.media,
      required this.type,
      required this.onCancel,
      super.key});
  final CLSharedMedia media;
  final ContentOrigin type;
  final void Function() onCancel;

  @override
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia =
      const CLSharedMedia(entries: ViewerEntities([]));
  late StoreEntity? targetCollection;
  late bool actionConfirmed;

  @override
  void initState() {
    actionConfirmed = widget.type == ContentOrigin.move;
    targetCollection = widget.media.collection;

    super.initState();
  }

  Future<bool> actor({
    required ViewerEntities currEntities,
    required Future<bool> Function() confirmAction,
    required Future<bool> Function() action,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    actionConfirmed = true;
    setState(() {});
    final bool res;
    if (await confirmAction()) {
      if (await action()) {
        selectedMedia = const CLSharedMedia(entries: ViewerEntities([]));
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
    required ViewerEntities currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == ContentOrigin.deleted) {
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
    required ViewerEntities currEntities,
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
        for (final item in currEntities.entities.cast<StoreEntity>()) {
          await item.updateWith(isDeleted: () => false);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> permanentlyDelete({
    required ViewerEntities currEntities,
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
        for (final item in currEntities.entities.cast<StoreEntity>()) {
          await item.delete();
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  Future<bool> delete({
    required ViewerEntities currEntities,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) async {
    if (widget.type == ContentOrigin.deleted) {
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
        for (final item in currEntities.entities.cast<StoreEntity>()) {
          await item.updateWith(isDeleted: () => true);
        }
        return true;
      },
      onUpdateSelectionmode: onUpdateSelectionmode,
    );
  }

  PreferredSizeWidget getCollection({required ViewerEntities currEntities}) {
    return CreateCollectionWizard(
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
      builder: ({
        required onUpdateSelectionmode,
        required selectionMode,
        required,
      }) {
        final currEntities =
            (selectionMode ? selectedMedia.entries : widget.media.entries);
        return WizardView(
          onCancel: widget.onCancel,
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
          onSelectionChanged: (ViewerEntities items) {
            selectedMedia = selectedMedia.copyWith(entries: items);
            setState(() {});
          },
          dialog: switch (widget.type) {
            ContentOrigin.deleted => null,
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
                          selectedMedia =
                              const CLSharedMedia(entries: ViewerEntities([]));
                          actionConfirmed = false;
                          targetCollection = null;
                          onUpdateSelectionmode(enable: false);
                          setState(() {});
                          // FIXME Refresh? Find someother logic
                          // ref.read(reloadProvider.notifier).reload();
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
  const WizardView(
      {required this.menu,
      required this.canSelect,
      required this.onSelectionChanged,
      required this.dialog,
      required this.onCancel,
      super.key});

  final WizardMenuItems menu;
  final bool canSelect;
  final PreferredSizeWidget? dialog;
  final void Function(ViewerEntities)? onSelectionChanged;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WizardLayout(
      title: menu.type.label,
      onCancel: onCancel,
      actions: [
        if (canSelect)
          // FIX ME: select ICon or text?
          const SelectionControlIcon(),
      ],
      wizard: dialog ??
          WizardDialog(
            option1: menu.option1,
            option2: menu.option2,
          ),
      child: WizardPreview(
        type: menu.type,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class KeepWithProgress extends StatelessWidget implements PreferredSizeWidget {
  const KeepWithProgress({
    required this.media2Move,
    required this.newParent,
    required this.onDone,
    super.key,
  });
  final ViewerEntities media2Move;
  final StoreEntity newParent;

  final Future<void> Function() onDone;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Progress>(
      stream: moveMultiple(
        items: media2Move,
        newParent: newParent,
        onDone: ({
          required ViewerEntities mediaMultiple,
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
    required ViewerEntities items,
    required StoreEntity newParent,
    required Future<void> Function({
      required ViewerEntities mediaMultiple,
    }) onDone,
  }) async* {
    final parentCollection = await newParent.dbSave();
    if (parentCollection == null || parentCollection.id == null) {
      throw Exception('failed to save parent collection');
    }

    final updatedItems = <StoreEntity>[];
    for (final (i, item) in items.entities.cast<StoreEntity>().indexed) {
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
    await onDone(mediaMultiple: ViewerEntities(updatedItems));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}

class SelectionControlIcon extends ConsumerWidget {
  const SelectionControlIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetSelectionMode(
      builder: ({
        required void Function({required bool enable}) onUpdateSelectionmode,
        required bool selectionMode,
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
 */
