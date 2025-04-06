import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'store.dart';

typedef ValueGetter<T> = T Function();

enum UpdateStrategy {
  skip,
  overwrite,
  mergeAppend,
}

@immutable
class EntityQuery extends StoreQuery<CLEntity> {
  const EntityQuery(super.map);
}
