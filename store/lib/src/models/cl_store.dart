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
    required this.tempFilePath,
    this.tempCollectionName = '*** Recently Captured',
  });
  final EntityStore store;
  final String tempCollectionName;
  final String tempFilePath;

  CLStore copyWith({
    EntityStore? store,
    String? tempCollectionName,
    String? tempFilePath,
  }) {
    return CLStore(
      store: store ?? this.store,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      tempFilePath: tempFilePath ?? this.tempFilePath,
    );
  }

  @override
  String toString() =>
      'CLStore(store: $store, tempCollectionName: $tempCollectionName, tempFilePath: $tempFilePath)';

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.tempCollectionName == tempCollectionName &&
        other.tempFilePath == tempFilePath;
  }

  @override
  int get hashCode =>
      store.hashCode ^ tempCollectionName.hashCode ^ tempFilePath.hashCode;

  Future<StoreEntity?> dbSave(
    StoreEntity entity, {
    String? path,
  }) async {
    final saved = await store.upsert(entity.entity, path: path);
    if (saved == null) {
      return null;
    }
    return StoreEntity(entity: saved, store: this);
  }

  Future<bool> delete(int entityId) async {
    final entity = await store.get(EntityQuery(null, {'id': entityId}));

    if (entity == null) {
      return false;
    }
    return store.delete(entity);
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
    required int? parentId,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    final mediaInDB = await store.get(
      EntityQuery(null, {'md5': mediaFile.md5, 'isCollection': 1}),
    );
    int? parentId0;
    if (parentId != null) {
      var parent = (await get(
        EntityQuery(null, {'id': parentId}),
      ))
          ?.entity;
      if (parent == null) {
        final tempParent = await createCollection(label: tempCollectionName);
        if (tempParent != null) {
          parent = (await tempParent.dbSave())?.entity;
        }
      }
      if (parent == null || parent.id == null) {
        throw Exception('missing parent; unable to create default collection');
      }
      if (!parent.isCollection) {
        throw Exception('Parent entity must be a collection.');
      }
      parentId0 = parent.id;
    } else {
      parentId0 = parentId;
    }

    if (mediaInDB != null && mediaInDB.id != null) {
      if (strategy == UpdateStrategy.skip) {
        return StoreEntity(entity: mediaInDB, store: this);
      } else {
        return updateMedia(
          mediaInDB.id!,
          label: label,
          description: description,
          parentId: () => parentId0,
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
    ValueGetter<String?>? pin,
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

  String createTempFile({required String ext}) {
    final fileBasename =
        'keep_it_temp_${DateTime.now().millisecondsSinceEpoch}';

    return '$tempFilePath/$fileBasename.$ext';
  }
}
