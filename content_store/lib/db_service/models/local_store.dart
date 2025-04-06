import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'entity_store_model.dart';

class LocalStore extends EntityStore {
  @override
  Future<CLEntity?> upsert(
    CLEntity curr, {
    CLEntity? prev,
    CLMediaContent? content,
  }) async {
    return store.upsert(curr);
  }

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
}

@immutable
class TheStore {
  const TheStore({
    required this.store,
    required this.downloadDir,
    required this.tempDir,
    this.tempCollectionName = '*** Recently Captured',
    this.onDelete,
    this.onCreate,
    this.onUpdate,
  });
  final EntityStore store;
  final String downloadDir;
  final String tempDir;
  final String tempCollectionName;
  final Future<bool> Function(CLEntity entity)? onDelete;
  final Future<bool> Function(CLEntity entity)? onCreate;
  final Future<bool> Function(CLEntity prev, CLEntity curr)? onUpdate;

  TheStore copyWith({
    EntityStore? store,
    String? downloadDir,
    String? tempDir,
    String? tempCollectionName,
    ValueGetter<Future<bool> Function(CLEntity entity)?>? onDelete,
    ValueGetter<Future<bool> Function(CLEntity entity)?>? onCreate,
    ValueGetter<Future<bool> Function(CLEntity prev, CLEntity curr)?>? onUpdate,
  }) {
    return TheStore(
      store: store ?? this.store,
      downloadDir: downloadDir ?? this.downloadDir,
      tempDir: tempDir ?? this.tempDir,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      onDelete: onDelete != null ? onDelete.call() : this.onDelete,
      onCreate: onCreate != null ? onCreate.call() : this.onCreate,
      onUpdate: onUpdate != null ? onUpdate.call() : this.onUpdate,
    );
  }

  @override
  String toString() {
    return 'LocalStore(store: $store, downloadDir: $downloadDir, tempDir: $tempDir, tempCollectionName: $tempCollectionName, onDelete: $onDelete, onCreate: $onCreate, onUpdate: $onUpdate)';
  }

  @override
  bool operator ==(covariant TheStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.downloadDir == downloadDir &&
        other.tempDir == tempDir &&
        other.tempCollectionName == tempCollectionName &&
        other.onDelete == onDelete &&
        other.onCreate == onCreate &&
        other.onUpdate == onUpdate;
  }

  @override
  int get hashCode {
    return store.hashCode ^
        downloadDir.hashCode ^
        tempDir.hashCode ^
        tempCollectionName.hashCode ^
        onDelete.hashCode ^
        onCreate.hashCode ^
        onUpdate.hashCode;
  }

  String createTempFile({required String ext}) {
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '$tempDir/$fileBasename.$ext';

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
    return upsert(
      CLEntity.collection(
        label: label,
        description: description?.call(),
        parentId: parentId?.call(),
      ),
    );
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

    final entity = await get(EntityQuery({'id': entityId}));

    if (entity == null) {
      throw Exception('entities do not exist.');
    }
    if (entity.isCollection == false) {
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
        final parent = await get(EntityQuery({'parentId': parentIdValue}));
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
  Future<CLEntity?> createMedia({
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
        return mediaInDB;
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
    // Copy files here (mediaFile, previewFile)
    final newMediaInDB = await upsert(newMedia);
    if (newMediaInDB == null) {
      // remove Files here
    }
    return newMediaInDB;
  }

  @override
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
  }) async {
    if (strategy == UpdateStrategy.skip) {
      throw Exception(
        'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
      );
    }

    final entity = await get(EntityQuery({'id': entityId}));

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
        final parent = await get(EntityQuery({'parentId': parentIdValue}));
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
    if (mediaFile != null) {
      // copy file here
      acceptMediaFiles(updated, mediaFile);
    }
    try {
      final mediaInDB = await upsert(updated);

      if (mediaInDB == null) {
        // failed. delete the new files
        releaseMediaFiles();
        throw Exception('media (id: ${updated.id}) update failed');
      } else {
        //delete old file here

        return mediaInDB;
      }
    } catch (e) {
      return entity;
    }
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
