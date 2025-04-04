import 'package:meta/meta.dart';

import 'cl_entity.dart';

enum DBQueries {
  mediaById,
  mediaByMD5,
  mediaByLabel,

  entitiesVisible,
  mediaByCollectionId,
  mediaByIdList,

  mediaPinned,
  mediaStaled,
  mediaDeleted,

  collections,
  rootCollections,
  visibleCollections
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class StoreReader {
  Future<T?> get<T>(
    Map<String, dynamic>? queryMap, {
    required T? Function(Map<String, dynamic>) fromMap,
  });

  Future<List<T>> getAll<T>(
    Map<String, dynamic>? queryMap, {
    required T? Function(Map<String, dynamic>) fromMap,
  });

  Future<List<CLEntity>> getEntitiesByIdList(List<int> idList) async =>
      getAll({'id': idList}, fromMap: CLEntity.fromMap);

  Future<List<CLEntity>> getEntitiesByParentId(int? parentId) async => getAll(
        {'parentId': parentId},
        fromMap: CLEntity.fromMap,
      );
}

@immutable
abstract class Store {
  const Store(this.reader);
  final StoreReader reader;

  Future<CLEntity?> upsertMedia(CLEntity media);
  Future<CLEntity?> updateMediaFromMap(
    Map<String, dynamic> map,
  );

  Future<void> deleteMedia(CLEntity media);

  void reloadStore();

  void dispose();
}
