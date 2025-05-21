import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';

import 'media_grouper.dart';

final groupedMediaProvider = StateProvider.family<
    List<ViewerEntityGroup<ViewerEntityMixin>>,
    MapEntry<ViewIdentifier, List<ViewerEntityMixin>>>((ref, mapEntry) {
  final groupBy = ref.watch(groupMethodProvider(mapEntry.key.parentID));

  return groupBy.getGrouped(mapEntry.value);
});
