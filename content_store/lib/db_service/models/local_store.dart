import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:content_store/storage_service/models/file_system/models/cl_directories.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

@immutable
class LocalStore implements EntityStoreModel {
  const LocalStore({
    required this.store,
    required this.directories,
    this.tempCollectionName = '*** Recently Captured',
    this.onDelete,
    this.onCreate,
    this.onUpdate,
  });
  final Store store;
  final CLDirectories directories;
  final String tempCollectionName;
  final Future<bool> Function(CLEntity entity)? onDelete;
  final Future<bool> Function(CLEntity entity)? onCreate;
  final Future<bool> Function(CLEntity prev, CLEntity curr)? onUpdate;

  LocalStore copyWith({
    Store? store,
    CLDirectories? directories,
  }) {
    return LocalStore(
      store: store ?? this.store,
      directories: directories ?? this.directories,
    );
  }

  @override
  String toString() {
    return 'StoreUpdater(store: $store, directories: $directories, tempCollectionName: $tempCollectionName)';
  }

  @override
  bool operator ==(covariant LocalStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.directories == directories &&
        other.tempCollectionName == tempCollectionName;
  }

  @override
  int get hashCode {
    return store.hashCode ^ directories.hashCode ^ tempCollectionName.hashCode;
  }

  String createTempFile({required String ext}) {
    final dir = directories.download.path;
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  @override
  Future<CLEntity?> createCollection({
    required String label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final collectionInDB =
        await store.get(EntityQuery({'label': label, 'isCollection': 1}));

    if (collectionInDB != null && collectionInDB.id != null) {
      if (!collectionInDB.isCollection) {
        throw Exception(
          'Entity with label $label is not a collection.',
        );
      }
      if (strategy == UpdateStrategy.skip) {
        return collectionInDB;
      } else {
        return updateCollection(
          collectionInDB.id!,
          description: description,
          parentId: parentId,
          strategy: strategy,
        );
      }
    }
    await upsert(
      CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
    );
    return null;
  }

  @override
  Future<CLEntity?> updateCollection(
    int entityId, {
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }

    final entity0 = await get(EntityQuery({'id': entityId}));

    if (entity0 == null) {
      throw Exception('entities do not exist.');
    }
    if (entity0.isCollection == false) {
      throw Exception(
        'All entities must be collections. One or more entities are not collections.',
      );
    }
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entity0.id == parentIdValue) {
        throw Exception(
          'Parent ID cannot be the same of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent = await get(EntityQuery({'parentId': parentIdValue}));
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    final updated = entity0.copyWith(
      label: label,
      description: description != null
          ? () => switch (strategy) {
                UpdateStrategy.mergeAppend =>
                  '${entity0.descriptionText}\n${description()}'.trim(),
                UpdateStrategy.overwrite => description.call(),
                UpdateStrategy.skip =>
                  throw Exception('UpdateStrategy.skip is not allowed'),
              }
          : null,
      parentId: parentId,
      isDeleted: isDeleted?.call(),
      isHidden: isHidden?.call(),
    );
    return upsert(updated);
  }

  @override
  Future<List<CLEntity>> updateCollectionMultiple(
    List<int> entityIds, {
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }
    if (entityIds.isEmpty) {
      throw Exception('No entity IDs provided.');
    }
    final entitiesIdsSet = entityIds.toSet();
    if (entitiesIdsSet.length != entityIds.length) {
      throw Exception('Duplicate entity IDs provided.');
    }
    if (entitiesIdsSet.any((e) => e <= 0)) {
      throw Exception('Invalid entity ID provided.');
    }
    final entities0 = await getAll(EntityQuery({'id': entityIds}));

    if (entities0.length != entityIds.length) {
      throw Exception('One or more entities do not exist.');
    }
    if (entities0.any((e) => e.isCollection == false)) {
      throw Exception(
        'All entities must be collections. One or more entities are not collections.',
      );
    }
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entities0.any((e) => e.id == parentIdValue)) {
        throw Exception(
          'Parent ID cannot be the same as any of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent = await get(EntityQuery({'parentId': parentIdValue}));
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }
    final entities = entities0.cast<CLEntity>();

    final updated = entities
        .map(
          (e) => e.copyWith(
            description: description != null
                ? () => switch (strategy) {
                      UpdateStrategy.mergeAppend =>
                        '${e.descriptionText}\n${description()}'.trim(),
                      UpdateStrategy.overwrite => description.call(),
                      UpdateStrategy.skip =>
                        throw Exception('UpdateStrategy.skip is not allowed'),
                    }
                : null,
            parentId: parentId,
            isDeleted: isDeleted?.call(),
            isHidden: isHidden?.call(),
          ),
        )
        .toList();
    return upsertAll(updated);
  }

  @override
  Future<CLEntity?> upsert(CLEntity entity) async => store.upsert(
        entity,
      );

  @override
  Future<List<CLEntity>> upsertAll(List<CLEntity> entitites) async {
    final mediaInDB = <CLEntity>[];
    for (final m in entitites) {
      var fromDB = await store.upsert(m);
      fromDB ??= await get(
        EntityQuery({
          if (m.id != null)
            'id': m.id
          else if (m.isCollection)
            'label': m.label
          else
            'md5': m.md5,
        }),
      );
      mediaInDB.add(fromDB!);
    }
    return mediaInDB;
  }

  @override
  Future<CLEntity?> createMedia({
    required CLMediaFile mediaFile,
    required int parentId,
    String? label,
    String? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) {
    // TODO: implement createMedia
    throw UnimplementedError();
  }

  @override
  Future<List<CLEntity>> updateMedia(
    int entityId, {
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
    ValueGetter<String>? pin,
  }) {
    // TODO: implement updateMedia
    throw UnimplementedError();
  }

  @override
  Future<List<CLEntity>> updateMediaMultiple(
    List<int> entityIds, {
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) {
    // TODO: implement updateMediaMultiple
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int entityId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMultiple(List<int> entityId) {
    // TODO: implement deleteMultiple
    throw UnimplementedError();
  }

  @override
  Future<CLEntity?> get([EntityQuery? query]) {
    return store.get(query as StoreQuery<CLEntity>?);
  }

  @override
  Future<List<CLEntity>> getAll([EntityQuery? query]) {
    return store.getAll(query as StoreQuery<CLEntity>?);
  }
}
