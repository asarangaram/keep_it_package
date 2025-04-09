import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

@immutable
class CLMediaFileGroup {
  const CLMediaFileGroup({
    required this.entries,
    required this.type,
    this.collection,
  });
  final List<CLMediaContent> entries;
  final StoreEntity? collection;
  final UniversalMediaSource? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
