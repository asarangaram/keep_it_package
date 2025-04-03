import 'package:meta/meta.dart';

import '../extensions/ext_list.dart';
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
  Future<T?> read<T>(StoreQuery<T> query);
  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  Future<T?> get<T>(DBQueries query, {List<Object?>? parameters}) async {
    final q = getQuery(query, parameters: parameters) as StoreQuery<T>;
    return read(q);
  }

  Future<List<T>> getMultiple<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) async {
    final q = getQuery(query, parameters: parameters) as StoreQuery<T>;
    return (await readMultiple<T>(q)).nonNullableList;
  }

  Future<List<CLEntity>> getEntitiesByIdList(List<int> idList) async =>
      getMultiple(
        DBQueries.mediaByIdList,
        parameters: ['(${idList.join(', ')})'],
      );

  Future<List<CLEntity>> getEntitiesByParentId(int? collectionId) async =>
      getMultiple(
        DBQueries.mediaByCollectionId,
        parameters: [collectionId],
      );

  Future<CLEntity?> getEntity({int? id, String? md5, String? label}) async {
    CLEntity? entity;
    if (id != null) {
      entity = await get<CLEntity>(DBQueries.mediaById, parameters: [id]);
    }
    if (entity != null && md5 != null) {
      entity = await get<CLEntity>(DBQueries.mediaByMD5, parameters: [md5]);
    }
    if (entity != null && label != null) {
      entity = await get<CLEntity>(DBQueries.mediaByLabel, parameters: [label]);
    }

    return entity;
  }
}

@immutable
abstract class Store {
  const Store(this.reader);
  final StoreReader reader;

  Future<CLEntity?> upsertMedia(CLEntity media, {List<CLEntity>? parents});
  //Future<CLMedia?> upsertNote(CLMedia note, List<CLMedia> mediaList);

  Future<CLEntity?> updateMediaFromMap(
    Map<String, dynamic> map,
  );

  Future<void> deleteMedia(CLEntity media);

  void reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);

  void dispose();
}
