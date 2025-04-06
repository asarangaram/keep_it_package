import 'package:flutter/foundation.dart';

import 'package:store/store.dart';

enum UpdateStrategy {
  skip,
  overwrite,
  mergeAppend,
}

@immutable
class EntityQuery extends StoreQuery<CLEntity> {
  const EntityQuery(super.map);
}

/* abstract class EntityStoreModel {
  Future<CLEntity?> get([EntityQuery? query]);
  Future<List<CLEntity>> getAll([EntityQuery? query]);

  Future<CLEntity?> upsert(CLEntity entity);

  Future<List<CLEntity>> upsertAll(List<CLEntity> entitites);

  Future<CLEntity?> createCollection({
    required String label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  });

  Future<CLEntity?> updateCollection(
    int entityId, {
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  });

  /// Updates multiple collection entities.
  ///
  /// This method allows batch updating of existing collection objects,
  /// applies the same `parentId`
  /// applying the same `description`, `parentId`, and update `strategy` to all.
  ///
  /// [entityIds] is the list of IDs of entities to update.
  ///   All entries must be collections and exist.
  ///   If any entity is not a collection or does not exist, an error will be thrown.
  /// [description] is a function that provides the new description to apply, depending on [strategy].
  ///   * Merges (appends) the description if [strategy] is [UpdateStrategy.mergeAppend].
  ///   * Replaces the description if [strategy] is [UpdateStrategy.overwrite].
  ///   * [UpdateStrategy.skip] is not allowed.
  ///   If null, the description will not be updated.
  /// [parentId] is a function that provides the new parent collection ID to assign, if applicable.
  ///   Can return null if you want to make the collection a root collection.
  ///   If null, the parent ID will not be updated.
  /// [isDeleted] is a function that provides the new deletion status.
  /// [isHidden] is a function that provides the new hidden status.
  /// Returns a list of updated [CLEntity] objects.
  Future<List<CLEntity>> updateCollectionMultiple(
    List<int> entityIds, {
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  });

  Future<CLEntity?> createMedia({
    required CLMediaFile mediaFile,
    required int parentId,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  });

  Future<List<CLEntity>> updateMediaMultiple(
    List<int> entityIds, {
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?> parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  });
  Future<CLEntity> updateMedia(
    int entityId, {
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String>? pin,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  });

  Future<void> delete(int entityId);
  Future<void> deleteMultiple(List<int> entityId);
} */
