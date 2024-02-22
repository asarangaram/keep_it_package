import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';
import 'dialogs.dart';

class TagsFolderView extends ConsumerWidget {
  const TagsFolderView({
    required this.label,
    required this.entities,
    required this.availableSuggestions,
    required this.onSelect,
    required this.onUpdate,
    required this.onDelete,
    required this.previewGenerator,
    required this.itemSize,
    required this.onCreateNew,
    super.key,
  });
  final String label;
  final List<Tag> entities;
  final List<Tag> availableSuggestions;
  final Future<bool> Function(BuildContext context, Tag tag) onSelect;
  final Future<bool> Function(List<Tag> selectedTags) onUpdate;

  final Future<bool> Function(List<Tag> selectedTags) onDelete;
  final Widget Function(BuildContext context, Tag tag) previewGenerator;
  final Size itemSize;

  final Future<bool> Function(BuildContext context, WidgetRef ref) onCreateNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      [
        if (availableSuggestions.isNotEmpty)
          CLMenuItem(
            title: 'Suggestions',
            icon: Icons.menu,
            onTap: () async {
              KeepItDialogs.onSuggestions(
                context,
                availableSuggestions: Tags(availableSuggestions),
                onSelectionDone: onUpdate,
              );

              return true;
            },
          ),
        CLMenuItem(
          title: 'Create New',
          icon: Icons.new_label,
          onTap: () => onCreateNew(context, ref),
        ),
      ]
    ];

    if (entities.isEmpty) {
      return KeepItMainView(
        pageBuilder: (context, quickMenuScopeKey) => Center(
          child: CLButtonsGrid(
            children2D: menuItems,
            alignment: Alignment.center,
          ),
        ),
      );
    }
    return KeepItMainView(
      title: label,
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      actionsBuilder: [
        (context, quickMenuScopeKey) {
          if (availableSuggestions.isEmpty) {
            return CLButtonIcon.standard(
              Icons.add,
              onTap: () => onCreateNew(context, ref),
            );
          } else {
            return CLQuickMenuAnchor(
              parentKey: quickMenuScopeKey,
              menuBuilder: (
                context,
                boxconstraints, {
                required void Function() onDone,
              }) {
                return CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(
                    kMinInteractiveDimension * 1.5,
                    kMinInteractiveDimension * 1.5,
                  ),
                  children2D: menuItems.insertOnDone(onDone),
                );
              },
              child: const CLIcon.standard(Icons.add),
            );
          }
        },
        (context, quickMenuScopeKey) {
          if (availableSuggestions.isEmpty) {
            return CLButtonIcon.small(
              Icons.admin_panel_settings,
              onTap: () async {
                final tag = await KeepItDialogs.showDialogUpsertTag(context);
                if (tag != null) {
                  await onUpdate([tag]);
                }
              },
            );
          } else {
            return CLQuickMenuAnchor(
              parentKey: quickMenuScopeKey,
              menuBuilder: (
                context,
                boxconstraints, {
                required void Function() onDone,
              }) {
                return CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(
                    kMinInteractiveDimension * 1.5,
                    kMinInteractiveDimension * 1.5,
                  ),
                  children2D: menuItems.insertOnDone(onDone),
                );
              },
              child: const CLIcon.standard(Icons.content_paste),
            );
          }
        },
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return TagsFolderViewitemBuilder(
          quickMenuScopeKey: quickMenuScopeKey,
          entities: entities,
          onTap: onSelect,
          onEdit: (context, tag) async {
            final updated = await KeepItDialogs.showDialogUpsertTag(
              context,
              entity: tag,
            );
            if (updated != null) {
              await onUpdate([updated]);
            }
            return true;
          },
          onDelete: onDeleteTag,
          previewGenerator: previewGenerator,
          itemSize: itemSize,
        );
      },
    );
  }

  Future<bool?> onDeleteTag(
    BuildContext context,
    Tag tag,
  ) async {
    switch (await showOkCancelAlertDialog(
      context: context,
      message: 'Are you sure that you want to delete?',
      okLabel: 'Yes',
      cancelLabel: 'No',
    )) {
      case OkCancelResult.ok:
        return onDelete([tag]);

      case OkCancelResult.cancel:
        return false;
    }
  }
}

class TagsFolderViewitemBuilder extends ConsumerWidget {
  const TagsFolderViewitemBuilder({
    required this.quickMenuScopeKey,
    required this.entities,
    required this.previewGenerator,
    required this.itemSize,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.lastupdatedID, // Must avoid to item !
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<Tag> entities;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onEdit;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onDelete;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onTap;
  final int? lastupdatedID;
  final Widget Function(BuildContext context, Tag tag) previewGenerator;
  final Size itemSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highLightIndex = lastupdatedID == null
        ? -1
        : entities.indexWhere((e) => e.id == lastupdatedID);
    return CLCustomGrid.fit(
      childSize: itemSize,
      itemCount: entities.length,
      layers: 2,
      controller: null,
      itemBuilder: (context, index, layer) {
        final tag = entities[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: quickMenuScopeKey,
              onEdit: () async => onEdit!.call(
                context,
                tag,
              ),
              onDelete: () async => onDelete!.call(
                context,
                tag,
              ),
              onTap: () async => onTap!.call(
                context,
                tag,
              ),
              child: CLAspectRationDecorated(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: previewGenerator(context, tag),
              ),
            ),
          );
        } else if (layer == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              entities[index].label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        throw Exception('Incorrect layer');
      },
    );
  }
}
