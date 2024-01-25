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
  Widget build(BuildContext context, WidgetRef ref) => const CLFullscreenBox(
        child: CLBackground(
          child: LoadTags(
            buildOnData: _TagsView.new,
          ),
        ),
      );
}

class _TagsView extends ConsumerStatefulWidget {
  const _TagsView(this.tags, {super.key});
  final Tags tags;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TagsViewState();
}

class _TagsViewState extends ConsumerState<_TagsView> {
  @override
  Widget build(BuildContext context) {
    final availableSuggestions = widget.tags.getSuggestions;

    final menuItems = [
      [
        CLMenuItem(
          title: 'Suggested\nTags',
          icon: Icons.menu,
          onTap: () async {
            TagsDialog.onSuggestions(
              context,
              availableSuggestions: availableSuggestions,
              onSelectionDone: (List<Tag> selectedTags) {
                ref.read(tagsProvider(null).notifier).upsertTags(selectedTags);
              },
            );

            return true;
          },
        ),
        CLMenuItem(
          title: 'Create New',
          icon: Icons.new_label,
          onTap: () async => TagsDialog.newTag(context),
        ),
      ]
    ];

    if (widget.tags.isEmpty) {
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
        toggleGridView,
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        final isGridView = ref.watch(isGridProvider);
        if (isGridView) {
          return TagsGrid(
            quickMenuScopeKey: quickMenuScopeKey,
            tags: widget.tags,
            onTapTag: (context, tag) async {
              unawaited(
                context.push(
                  '/collections/by_tag_id/${tag.id}',
                ),
              );
              return true;
            },
            onEditTag: TagsDialog.updateTag,
            onDeleteTag: onDeleteTag,
          );
        }
        return TagsList(
          tags: widget.tags,
          onTapTag: (context, tag) async {
            unawaited(
              context.push(
                '/collections/by_tag_id/${tag.id}',
              ),
            );
            return true;
          },
          onEditTag: TagsDialog.updateTag,
          onDeleteTag: onDeleteTag,
        );
      },
    );
  }

  Widget toggleGridView(
    BuildContext context,
    GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  ) {
    final isGridView = ref.watch(isGridProvider);
    return CLButtonIcon.small(
      isGridView ? Icons.view_list : Icons.widgets,
      onTap: () {
        ref.read(isGridProvider.notifier).state = !isGridView;
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
        ref.read(tagsProvider(null).notifier).deleteTag(tag);
        return true;
      case OkCancelResult.cancel:
        return false;
    }
  }
}
