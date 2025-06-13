import 'package:flutter/foundation.dart';

import 'store_task.dart';

@immutable
class StoreTasks {
  const StoreTasks(this.tasks);
  final List<StoreTask> tasks;
}
