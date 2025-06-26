import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entities.dart';
import '../../common/models/viewer_entity_mixin.dart';

import 'media_grouper.dart';

final groupedMediaProvider =
    StateProvider.family<List<ViewerEntityGroup<ViewerEntity>>, ViewerEntities>(
        (ref, entities) {
  final groupBy = ref.watch(groupMethodProvider);

  return groupBy.getGrouped(entities);
});
