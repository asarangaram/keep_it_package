import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';
import 'collections_dialog.dart';

class CollectionFolderView extends ConsumerWidget {
  const CollectionFolderView({
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
  final List<Collection> entities;
  final List<Collection> availableSuggestions;
  final Future<bool> Function(BuildContext context, Collection entity) onSelect;
  final Future<bool> Function(List<Collection> selectedTags) onUpdate;

  final Future<bool> Function(List<Collection> selectedTags) onDelete;
  final Widget Function(BuildContext context, Collection entity)
      previewGenerator;
  final Size itemSize;

  final Future<bool> Function(BuildContext context, WidgetRef ref) onCreateNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      [
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
          return CLButtonIcon.standard(
            Icons.add,
            onTap: () => onCreateNew(context, ref),
          );
        },
        (context, quickMenuScopeKey) {
          if (availableSuggestions.isEmpty) {
            return CLButtonIcon.small(
              Icons.admin_panel_settings,
              onTap: () async {
                final tag = await CollectionsDialog.upsert(context);
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
        return CollectionFolderViewitemBuilder(
          quickMenuScopeKey: quickMenuScopeKey,
          entities: entities,
          onTap: onSelect,
          onEdit: (context, entity) async {
            final tag = await CollectionsDialog.upsert(context, entity: entity);
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
    Collection entity,
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

class CollectionFolderViewitemBuilder extends ConsumerWidget {
  const CollectionFolderViewitemBuilder({
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
  final List<Collection> entities;
  final Future<bool?> Function(
    BuildContext context,
    Collection entity,
  )? onEdit;
  final Future<bool?> Function(
    BuildContext context,
    Collection entity,
  )? onDelete;
  final Future<bool?> Function(
    BuildContext context,
    Collection entity,
  )? onTap;
  final int? lastupdatedID;
  final Widget Function(BuildContext context, Collection entity)
      previewGenerator;
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
        final entity = entities[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: quickMenuScopeKey,
              onEdit: () async => onEdit!.call(
                context,
                entity,
              ),
              onDelete: () async => onDelete!.call(
                context,
                entity,
              ),
              onTap: () async => onTap!.call(
                context,
                entity,
              ),
              child: CLAspectRationDecorated(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: previewGenerator(context, entity),
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
