import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:flutter/foundation.dart';

import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

@immutable
class CLMediaFileGroup {
  const CLMediaFileGroup({
    required this.entries,
    required this.contentOrigin,
    this.collection,
  });
  final List<CLMediaContent> entries;
  final StoreEntity? collection;
  final ContentOrigin contentOrigin;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
