import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../widgets/keep_it_main_view.dart';
import '../widgets/keepit_grid_item.dart';
import '../widgets/tags_dialogs.dart';
import '../widgets/tags_empty.dart';

class KeepItGrid extends StatelessWidget {
  const KeepItGrid({
    required this.label,
    required this.entities,
    required this.availableSuggestions,
    required this.onSelect,
    required this.onUpdate,
    required this.onDelete,
    required this.onCreate,
    required this.onEdit,
    required this.previewGenerator,
    super.key,
  });
  final String label;
  final List<CollectionBase> entities;
  final List<CollectionBase> availableSuggestions;
  final Future<bool> Function(BuildContext context, CollectionBase entity)
      onSelect;
  final void Function(List<CollectionBase> selectedTags) onUpdate;
  final Future<bool> Function(BuildContext context) onCreate;
  final Future<bool> Function(BuildContext context, CollectionBase tag) onEdit;
  final void Function(List<CollectionBase> selectedTags) onDelete;
  final Widget Function(BuildContext context, CollectionBase tag)
      previewGenerator;

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      [
        CLMenuItem(
          title: 'Suggestions',
          icon: Icons.menu,
          onTap: () async {
            TagsDialog.onSuggestions(
              context,
              availableSuggestions:
                  Tags(availableSuggestions.map(Tag.fromBase).toList()),
              onSelectionDone: onUpdate,
            );

            return true;
          },
        ),
        CLMenuItem(
          title: 'Create New',
          icon: Icons.new_label,
          onTap: () => onCreate(context),
        ),
      ]
    ];

    if (entities.isEmpty) {
      return KeepItMainView(
        pageBuilder: (context, quickMenuScopeKey) => TagsEmpty(
          menuItems: menuItems,
        ),
      );
    }
    return KeepItMainView(
      title: label,
      actionsBuilder: [
        (context, quickMenuScopeKey) {
          if (availableSuggestions.isEmpty) {
            return CLButtonIcon.standard(
              Icons.add,
              onTap: () => TagsDialog.newTag(context),
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
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return KeepItGridItem(
          quickMenuScopeKey: quickMenuScopeKey,
          entities: entities,
          onTap: onSelect,
          onEdit: onEdit,
          onDelete: onDeleteTag,
          previewGenerator: previewGenerator,
        );
      },
    );
  }

  Future<bool?> onDeleteTag(
    BuildContext context,
    CollectionBase tag,
  ) async {
    switch (await showOkCancelAlertDialog(
      context: context,
      message: 'Are you sure that you want to delete?',
      okLabel: 'Yes',
      cancelLabel: 'No',
    )) {
      case OkCancelResult.ok:
        onDelete([Tag.fromBase(tag)]);

        return true;
      case OkCancelResult.cancel:
        return false;
    }
  }
}
