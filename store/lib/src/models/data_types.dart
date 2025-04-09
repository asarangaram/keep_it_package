import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'store_query.dart';

typedef ValueGetter<T> = T Function();

enum UpdateStrategy {
  skip,
  overwrite,
  mergeAppend,
}

@immutable
class EntityQuery extends StoreQuery<CLEntity> {
  const EntityQuery(super.storeIdentity, super.map);
}
