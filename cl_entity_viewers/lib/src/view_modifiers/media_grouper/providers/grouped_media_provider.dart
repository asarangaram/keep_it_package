import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../entity/models/viewer_entity_mixin.dart';
import '../../../gallery_grid_view/models/tab_identifier.dart';

import 'media_grouper.dart';

final groupedMediaProvider = StateProvider.family<
    List<ViewerEntityGroup<ViewerEntityMixin>>,
    MapEntry<TabIdentifier, List<ViewerEntityMixin>>>((ref, mapEntry) {
  final groupBy = ref.watch(groupMethodProvider(mapEntry.key.tabId));

  return groupBy.getGrouped(mapEntry.value);
});
