import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_tasks/src/models/content_origin.dart';
import 'package:store_tasks/src/widgets/handle_task.dart';

import '../providers/active_task.dart';
import '../providers/store_tasks.dart';

class StoreTaskWizard extends ConsumerWidget {
  const StoreTaskWizard({required this.type, required this.onDone, super.key});
  final String type;
  final void Function({required bool isCompleted}) onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentOrigin =
        ContentOrigin.values.asNameMap()[type] ?? ContentOrigin.stale;
    final storeTasks = ref.watch(storeTasksProvider(contentOrigin));
    if (storeTasks.tasks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onDone(isCompleted: true);
      });
      return WizardLayout(
        title: contentOrigin.label,
        onCancel: () => onDone(isCompleted: false),
        child: const Center(child: Text('Task Queue is empty')),
      );
    }
    final task = storeTasks.tasks.first;
    return CLFullscreenBox(
      child: ProviderScope(
        overrides: [
          activeTaskProvider.overrideWith((ref) => ActiveTaskNotifier(
              ActiveStoreTask(
                  task: task,
                  selectedMedia: const [],
                  itemsConfirmed:
                      // You can't modify the item list when move is selected
                      // as move carries already selected items
                      task.contentOrigin == ContentOrigin.move ? true : null,
                  // delete will modify with itself, no collection is required.
                  targetConfirmed: task.contentOrigin == ContentOrigin.deleted
                      ? true
                      : null)))
        ],
        child: CLEntitiesGridViewScope(
          child: HandleTask(
              onDone: ref.read(storeTasksProvider(contentOrigin).notifier).pop),
        ),
      ),
    );
  }
}
