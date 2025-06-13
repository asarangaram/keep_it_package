import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:flutter/foundation.dart';

import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

@immutable
class CLMediaFileGroup {
  const CLMediaFileGroup({
    required this.entries,
    required this.type,
    this.collection,
  });
  final List<CLMediaContent> entries;
  final StoreEntity? collection;
  final StoreTaskType? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
