import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../providers/state_providers.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import '../widgets/tags_dialogs.dart';
import '../widgets/tags_empty.dart';
import '../widgets/tags_grid.dart';
import '../widgets/tags_list.dart';

class TagsView extends ConsumerWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CLFullscreenBox(
        child: CLBackground(
          child: LoadTags(
            buildOnData: (tags) => CollectionBaseView(
              tags: tags,
              availableSuggestions: Tags(
                suggestedTags.where((element) {
                  return !tags.entries
                      .map((e) => e.label)
                      .contains(element.label);
                }).toList(),
              ),
              onUpdate: (List<Tag> selectedTags) {
                ref.read(tagsProvider(null).notifier).upsertTags(selectedTags);
              },
              onDelete: (List<Tag> selectedTags) {
                ref.read(tagsProvider(null).notifier).deleteTags(selectedTags);
              },
              onCreate: (context) async =>
                  (await TagsDialog.newTag(context)) != null,
              onEdit: (context, tag) async =>
                  await TagsDialog.updateTag(context, Tag.fromBase(tag)) !=
                  null,
            ),
          ),
        ),
      );
}

class CollectionBaseView extends StatelessWidget {
  const CollectionBaseView({
    required this.tags,
    required this.availableSuggestions,
    required this.onUpdate,
    required this.onDelete,
    required this.onCreate,
    required this.onEdit,
    super.key,
  });
  final Tags tags;
  final Tags availableSuggestions;
  final void Function(List<Tag> selectedTags) onUpdate;
  final Future<bool> Function(BuildContext context) onCreate;
  final Future<bool> Function(BuildContext context, CollectionBase tag) onEdit;
  final void Function(List<Tag> selectedTags) onDelete;
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      [
        CLMenuItem(
          title: 'Suggested\nTags',
          icon: Icons.menu,
          onTap: () async {
            TagsDialog.onSuggestions(
              context,
              availableSuggestions: availableSuggestions,
              onSelectionDone: onUpdate,
            );

            return true;
          },
        ),
        CLMenuItem(
          title: 'Create Tag',
          icon: Icons.new_label,
          onTap: () => onCreate(context),
        ),
      ]
    ];

    if (tags.isEmpty) {
      return KeepItMainView(
        pageBuilder: (context, quickMenuScopeKey) => TagsEmpty(
          menuItems: menuItems,
        ),
      );
    }
    return KeepItMainView(
      title: 'Tags',
      actionsBuilder: [
        (context, quickMenuScopeKey) {
          if (availableSuggestions.entries.isEmpty) {
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
        return TagsGrid(
          quickMenuScopeKey: quickMenuScopeKey,
          tags: tags,
          onTap: (context, tag) async {
            unawaited(
              context.push(
                '/collections/by_tag_id/${tag.id}',
              ),
            );
            return true;
          },
          onEdit: onEdit,
          onDelete: onDeleteTag,
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
