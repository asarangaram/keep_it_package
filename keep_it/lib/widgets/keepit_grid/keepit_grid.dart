import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../dialogs.dart';
import '../keep_it_main_view.dart';
import 'keepit_grid_item.dart';

class KeepItGrid extends ConsumerWidget {
  const KeepItGrid({
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
  final List<CollectionBase> entities;
  final List<CollectionBase> availableSuggestions;
  final Future<bool> Function(BuildContext context, CollectionBase entity)
      onSelect;
  final Future<bool> Function(List<CollectionBase> selectedTags) onUpdate;

  final Future<bool> Function(List<CollectionBase> selectedTags) onDelete;
  final Widget Function(BuildContext context, CollectionBase entity)
      previewGenerator;
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
                final tag = await KeepItDialogs.upsert(context);
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
        return KeepItGridItem(
          quickMenuScopeKey: quickMenuScopeKey,
          entities: entities,
          onTap: onSelect,
          onEdit: (context, entity) async {
            final tag = await KeepItDialogs.upsert(context, entity: entity);
            if (tag != null) {
              await onUpdate([tag]);
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
    CollectionBase entity,
  ) async {
    switch (await showOkCancelAlertDialog(
      context: context,
      message: 'Are you sure that you want to delete?',
      okLabel: 'Yes',
      cancelLabel: 'No',
    )) {
      case OkCancelResult.ok:
        return onDelete([entity]);

      case OkCancelResult.cancel:
        return false;
    }
  }
}
