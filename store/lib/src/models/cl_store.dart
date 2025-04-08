import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import 'data_types.dart';
import 'store_entity.dart';

@immutable
class CLStore {
  const CLStore({
    required this.store,
    this.tempCollectionName = '*** Recently Captured',
  });
  final EntityStore store;
  final String tempCollectionName;

  CLStore copyWith({
    EntityStore? store,
    String? tempCollectionName,
  }) {
    return CLStore(
      store: store ?? this.store,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
    );
  }

  @override
  String toString() =>
      'CLStore(store: $store, tempCollectionName: $tempCollectionName)';

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.tempCollectionName == tempCollectionName;
  }

  @override
  int get hashCode => store.hashCode ^ tempCollectionName.hashCode;

  Future<StoreEntity?> createCollection({
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
        return StoreEntity(entity: collectionInDB, store: this);
      } else {
        return updateCollection(
          collectionInDB.id!,
          description: description,
          parentId: parentId,
          strategy: strategy,
        );
      }
    }
    final entityFromDB = await store.upsert(
      CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
    );
    if (entityFromDB == null) return null;
    return StoreEntity(entity: entityFromDB, store: this);
  }

  Future<StoreEntity?> createMedia({
    required CLMediaFile mediaFile,
    required int parentId,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final mediaInDB =
        await store.get(EntityQuery({'md5': mediaFile.md5, 'isCollection': 1}));

    if (mediaInDB != null && mediaInDB.id != null) {
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(entity: mediaInDB, store: this);
      } else {
        return updateMedia(
          mediaInDB.id!,
          label: label,
          description: description,
          parentId: () => parentId,
          strategy: strategy,
        );
      }
    }

    final newMedia = CLEntity.media(
      label: label != null ? label() : null,
      description: description != null ? description() : null,
      parentId: parentId,
      md5: mediaFile.md5,
      fileSize: mediaFile.fileSize,
      mimeType: mediaFile.mimeType,
      type: mediaFile.type.name,
      extension: mediaFile.fileSuffix,
      createDate: mediaFile.createDate,
      height: mediaFile.height,
      width: mediaFile.width,
      duration: mediaFile.duration,
      isDeleted: false,
    );

    final entityFromDB =
        await store.upsert(newMedia, mediaFile: mediaFile.path);

    if (entityFromDB == null) return null;
    return StoreEntity(entity: entityFromDB, store: this);
  }

  Future<StoreEntity?> updateCollection(
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

    final entity = await store.get(EntityQuery({'id': entityId}));

    if (entity == null) {
      throw Exception('entities do not exist.');
    }
    if (entity.isCollection) {}
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entity.id == parentIdValue) {
        throw Exception(
          'Parent ID cannot be the same of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent =
            (await get(EntityQuery({'parentId': parentIdValue})))?.entity;
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    final updated = entity.copyWith(
      label: label,
      description: description != null
          ? () => switch (strategy) {
                UpdateStrategy.mergeAppend =>
                  '${entity.descriptionText}\n${description()}'.trim(),
                UpdateStrategy.overwrite => description.call(),
                UpdateStrategy.skip =>
                  throw Exception('UpdateStrategy.skip is not allowed'),
              }
          : null,
      parentId: parentId,
      isDeleted: isDeleted?.call(),
      isHidden: isHidden?.call(),
    );
    final entityFromDB = await store.upsert(updated, prev: entity);
    if (entityFromDB == null) return null;
    return StoreEntity(entity: entityFromDB, store: this);
  }

  Future<StoreEntity?> updateMedia(
    int entityId, {
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String>? pin,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }

    final entity = await store.get(EntityQuery({'id': entityId}));

    if (entity == null) {
      throw Exception('entities do not exist.');
    }
    if (entity.isCollection) {
      throw Exception(
        'All entities must be collections. One or more entities are not collections.',
      );
    }
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entity.id == parentIdValue) {
        throw Exception(
          'Parent ID cannot be the same of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent =
            await store.get(EntityQuery({'parentId': parentIdValue}));
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    final updated = entity.copyWith(
      label: label,
      description: description != null
          ? () => switch (strategy) {
                UpdateStrategy.mergeAppend =>
                  '${entity.descriptionText}\n${description()}'.trim(),
                UpdateStrategy.overwrite => description.call(),
                UpdateStrategy.skip =>
                  throw Exception('UpdateStrategy.skip is not allowed'),
              }
          : null,
      parentId: parentId,
      isDeleted: isDeleted?.call(),
      isHidden: isHidden?.call(),
      pin: pin,
      md5: mediaFile == null ? null : () => mediaFile.md5,
      fileSize: mediaFile == null ? null : () => mediaFile.fileSize,
      mimeType: mediaFile == null ? null : () => mediaFile.mimeType,
      type: mediaFile == null ? null : () => mediaFile.type.name,
      extension: mediaFile == null ? null : () => mediaFile.fileSuffix,
      createDate: mediaFile == null ? null : () => mediaFile.createDate,
      height: mediaFile == null ? null : () => mediaFile.height,
      width: mediaFile == null ? null : () => mediaFile.width,
      duration: mediaFile == null ? null : () => mediaFile.duration,
    );

    final entityFromDB = await store.upsert(
          updated,
          prev: entity,
          mediaFile: mediaFile?.path,
        ) ??
        entity;
    return StoreEntity(entity: entityFromDB, store: this);
  }

  Future<List<StoreEntity?>> updateMultiple(
    List<int> entityIds, {
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
    final entities0 = await store.getAll(EntityQuery({'id': entityIds}));

    if (entities0.length != entityIds.length) {
      throw Exception('One or more entities do not exist.');
    }

    if (entities0.any((e) => e.isCollection)) {
      throw Exception("label can't be updated for collection");
    }
    // Don't support mix
    if (entities0.any((e) => entities0[0].isCollection)) {
      throw Exception("mix of collections and media can't be updated");
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
        final parent =
            await store.get(EntityQuery({'parentId': parentIdValue}));
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }
    final entities = entities0.cast<CLEntity>();

    final updatedEntitites = <CLEntity?>[];
    for (final entity in entities) {
      final updated = entity
        ..copyWith(
          description: description != null
              ? () => switch (strategy) {
                    UpdateStrategy.mergeAppend =>
                      '${entity.descriptionText}\n${description()}'.trim(),
                    UpdateStrategy.overwrite => description.call(),
                    UpdateStrategy.skip =>
                      throw Exception('UpdateStrategy.skip is not allowed'),
                  }
              : null,
          parentId: parentId,
          isDeleted: isDeleted?.call(),
          isHidden: isHidden?.call(),
        );

      updatedEntitites.add(await store.upsert(updated));
    }

    return updatedEntitites
        .map(
          (entityFromDB) => entityFromDB == null
              ? null
              : StoreEntity(entity: entityFromDB, store: this),
        )
        .toList();
  }

  Future<void> delete(int entityId) async {
    final entity = await store.get(EntityQuery({'id': entityId}));

    if (entity == null) {
      throw Exception('entities do not exist.');
    }
    await store.delete(entity);
  }

  Future<StoreEntity?> get([EntityQuery? query]) async {
    final entityFromDB = await store.get(query as StoreQuery<CLEntity>?);
    if (entityFromDB == null) {
      return null;
    }
    return StoreEntity(
      entity: entityFromDB,
      store: this,
    );
  }

  Future<List<StoreEntity>> getAll([EntityQuery? query]) async {
    final entititesFromDB = await store.getAll(query as StoreQuery<CLEntity>?);
    return entititesFromDB
        .cast<CLEntity>()
        .map(
          (entityFromDB) => StoreEntity(entity: entityFromDB, store: this),
        )
        .toList();
  }
}
