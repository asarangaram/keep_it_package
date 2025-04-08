import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'data_types.dart';
import 'entity_store.dart';
import 'store.dart';
import 'store_entity.dart';

class ClStoreInterface {}

@immutable
class CLStore {
  const CLStore({
    required this.store,
    required this.mediaPath,
    required this.previewPath,
    this.tempCollectionName = '*** Recently Captured',
  });
  final EntityStore store;
  final String tempCollectionName;
  final String mediaPath;
  final String previewPath;

  CLStore copyWith({
    EntityStore? store,
    String? tempCollectionName,
    String? mediaPath,
    String? previewPath,
  }) {
    return CLStore(
      store: store ?? this.store,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      mediaPath: mediaPath ?? this.mediaPath,
      previewPath: previewPath ?? this.previewPath,
    );
  }

  @override
  String toString() {
    return 'CLStore(store: $store, tempCollectionName: $tempCollectionName, mediaPath: $mediaPath, previewPath: $previewPath)';
  }

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.tempCollectionName == tempCollectionName &&
        other.mediaPath == mediaPath &&
        other.previewPath == previewPath;
  }

  @override
  int get hashCode {
    return store.hashCode ^
        tempCollectionName.hashCode ^
        mediaPath.hashCode ^
        previewPath.hashCode;
  }

  Future<StoreEntity?> dbSave(
    StoreEntity entity, {
    String? path,
  }) async {
    final CLEntity? prev;
    final curr = entity.entity;
    CLEntity? updated;

    if (entity.id == null) {
      prev = null;
      final timeNow = DateTime.now();
      updated = curr.copyWith(createDate: () => timeNow, updatedDate: timeNow);
    } else {
      prev = await store.get(
        EntityQuery(
          null,
          {'id': entity.entity.id},
        ),
      );
      if (prev == null) {
        throw Exception('Entity with id not found');
      }
      if ((prev.md5 == curr.md5) && path != null) {
        throw Exception('path is not expected');
      }
      if (curr.isSame(prev)) {
        // nothing to update!
        return StoreEntity(entity: prev, store: this);
      } else if (curr.isContentSame(prev)) {
        updated = curr.copyWith(
          updatedDate: DateTime.now(),
        );
      } else {
        updated = curr;
      }
    }

    /// FIXME: Copy the file [path] to destination.
    try {
      final entityFromDB = await store.upsert(updated);
      if (entityFromDB == null) throw Exception('failed to update DB');
      // FIXME remove file from prev
      return StoreEntity(entity: updated, store: this);
    } catch (e) {
      // FIXME Remove recently updated file
      if (prev == null) return null;
      return StoreEntity(entity: prev, store: this);
    }
  }

  Future<void> delete(int entityId) async {
    final entity = await store.get(EntityQuery(null, {'id': entityId}));

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

  Future<StoreEntity?> createCollection({
    required String label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final collectionInDB =
        await store.get(EntityQuery(null, {'label': label, 'isCollection': 1}));

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

    return StoreEntity(
      entity: CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
      store: this,
    );
  }

  Future<StoreEntity?> createMedia({
    required CLMediaFile mediaFile,
    required int parentId,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final mediaInDB = await store.get(
      EntityQuery(null, {'md5': mediaFile.md5, 'isCollection': 1}),
    );

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

    return StoreEntity(
      entity: CLEntity.media(
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
      ),
      store: this,
      path: mediaFile.path,
    );
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

    final entity = await store.get(EntityQuery(null, {'id': entityId}));

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
        final parent = (await get(
          EntityQuery(null, {'parentId': parentIdValue}),
        ))
            ?.entity;
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      entity: entity.copyWith(
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
      ),
      store: this,
    );
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

    final entity = await store.get(EntityQuery(null, {'id': entityId}));

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
            await store.get(EntityQuery(null, {'parentId': parentIdValue}));
        if (parent == null) {
          throw Exception('Parent entity does not exist.');
        }
        if (!parent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
      }
    }

    return StoreEntity(
      entity: entity.copyWith(
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
      ),
      store: this,
      path: mediaFile?.path,
    );
  }
}
