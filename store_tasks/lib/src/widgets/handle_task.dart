import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/providers/active_task.dart';
import 'package:store_tasks/src/widgets/keep_with_progress.dart';

import 'items_preview.dart';
import 'pick_collection.dart';
import 'selection_control_icon.dart';
import 'wizard_menu_items.dart';

class HandleTask extends ConsumerWidget {
  const HandleTask({required this.onDone, super.key});
  final void Function() onDone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTask = ref.watch(activeTaskProvider);
    return GetSelectionMode(builder: ({
      required onUpdateSelectionmode,
      required selectionMode,
    }) {
      PreferredSizeWidget? wizard;
      if (activeTask.itemsConfirmed == null) {
        final menu = WizardMenuItems.moveOrCancel(
            type: activeTask.contentOrigin,
            keepActionLabel:
                activeTask.keepActionLabel(selectionMode: selectionMode),
            deleteActionLabel:
                activeTask.deleteActionLabel(selectionMode: selectionMode),
            keepAction: (activeTask
                    .currEntities(selectionMode: selectionMode)
                    .isEmpty)
                ? null
                : () async {
                    // If action requires confirmation, pop out the dialog
                    ref.read(activeTaskProvider.notifier).itemsConfirmed = true;
                    return true;
                  },
            deleteAction:
                (activeTask.currEntities(selectionMode: selectionMode).isEmpty)
                    ? null
                    : () async {
                        // If action requires confirmation, pop out the dialog
                        ref.read(activeTaskProvider.notifier).itemsConfirmed =
                            false;
                        return false;
                      });
        wizard = WizardDialog(
          option1: menu.option1,
          option2: menu.option2,
        );
      } else if (activeTask.targetConfirmed == null) {
        wizard = PickCollection(
          collection: activeTask.collection as StoreEntity?,
          isValidSuggestion: (collection) {
            return !collection.data.isDeleted;
          },
          onDone: (collection) {
            if (collection.id != null) {
              ref.read(activeTaskProvider.notifier).target = collection;
            }
          },
        );
      } else {
        wizard = KeepWithProgress(
            media2Move: ViewerEntities(
                activeTask.currEntities(selectionMode: selectionMode)),
            newParent: activeTask.collection! as StoreEntity,
            onDone: onDone);
      }

      return WizardLayout2(
        title: activeTask.contentOrigin.label,
        onCancel: onDone,
        actions: [
          if (activeTask.itemsConfirmed == null)
            if (activeTask.selectable) const SelectionControlIcon(),
        ],
        wizard: wizard,
        child: const WizardPreview(),
      );
    });
  }
}
