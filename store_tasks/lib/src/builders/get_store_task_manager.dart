import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_tasks/src/models/store_task_manager.dart';

import '../models/content_origin.dart';
import '../providers/store_tasks.dart';

class GetStoreTaskManager extends ConsumerWidget {
  const GetStoreTaskManager({
    required this.taskType,
    required this.builder,
    super.key,
  });
  final ContentOrigin taskType;
  final Widget Function(StoreTaskManager taskTaskManager) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskTaskManager = ref.watch(storeTasksProvider(taskType).notifier);
    return builder(taskTaskManager);
  }
}
