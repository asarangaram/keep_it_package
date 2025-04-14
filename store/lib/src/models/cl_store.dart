import 'dart:io';

import 'package:cl_media_tools/cl_media_tools.dart';

import 'package:meta/meta.dart';

import 'cl_entity.dart';
import 'data_types.dart';
import 'entity_store.dart';
import 'progress.dart';
import 'store_entity.dart';
import 'store_query.dart';

class ClStoreInterface {}

@immutable
class CLStore {
  factory CLStore() {
    return const CLStore._();
  }
  const CLStore._({
    this.store,
    this.tempFilePath,
    this.tempCollectionName = '*** Recently Captured',
    this.isLoading = false,
    this.errorMsg = '',
  });
  CLStore register({
    required EntityStore store,
    required String tempFilePath,
  }) {
    return copyWith(
      store: () => store,
      tempFilePath: () => tempFilePath,
      isLoading: false,
      errorMsg: '',
    );
  }

  CLStore error(String errorMsg) {
    if (errorMsg.isEmpty) {
      throw Exception("errorMsg can't be empty");
    }
    return copyWith(
      store: () => null,
      tempFilePath: () => null,
      isLoading: false,
      errorMsg: errorMsg,
    );
  }

  CLStore loading() {
    return copyWith(
      store: () => null,
      tempFilePath: () => null,
      isLoading: true,
      errorMsg: '',
    );
  }

  final EntityStore? store;
  final String tempCollectionName;
  final String? tempFilePath;
  final bool isLoading;
  final String errorMsg;

  CLStore copyWith({
    ValueGetter<EntityStore?>? store,
    ValueGetter<String?>? tempFilePath,
    String? tempCollectionName,
    bool? isLoading,
    String? errorMsg,
  }) {
    return CLStore._(
      store: store != null ? store.call() : this.store,
      tempCollectionName: tempCollectionName ?? this.tempCollectionName,
      tempFilePath:
          tempFilePath != null ? tempFilePath.call() : this.tempFilePath,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  String toString() {
    return 'CLStore(store: $store, tempCollectionName: $tempCollectionName, tempFilePath: $tempFilePath, isLoading: $isLoading, errorMsg: $errorMsg)';
  }

  @override
  bool operator ==(covariant CLStore other) {
    if (identical(this, other)) return true;

    return other.store == store &&
        other.tempCollectionName == tempCollectionName &&
        other.tempFilePath == tempFilePath &&
        other.isLoading == isLoading &&
        other.errorMsg == errorMsg;
  }

  @override
  int get hashCode {
    return store.hashCode ^
        tempCollectionName.hashCode ^
        tempFilePath.hashCode ^
        isLoading.hashCode ^
        errorMsg.hashCode;
  }

  bool get isInitialized => tempFilePath != null && store != null;

  T withStore<T>(T Function(EntityStore store) cb) {
    return (tempFilePath != null && store != null)
        ? cb(store!)
        : throw Exception('Store is not initialized');
  }

  Stream<T> withStoreStream<T>(
    Stream<T> Function(EntityStore store) cb,
  ) {
    return (tempFilePath != null && store != null)
        ? cb(store!)
        : Stream.error(Exception('Store is not initialized'));
  }

  Future<StoreEntity?> dbSave(
    StoreEntity entity, {
    String? path,
  }) async {
    Future<StoreEntity?>? cb(EntityStore store0) async {
      final saved = await store0.upsert(entity.data, path: path);
      if (saved == null) {
        return null;
      }
      return StoreEntity(entity: saved, store: this);
    }

    return withStore(cb);
  }

  Future<bool> delete(int entityId) async {
    Future<bool> cb(EntityStore store0) async {
      final entity = await store0.get(EntityQuery(null, {'id': entityId}));

      if (entity == null) {
        return false;
      }
      return store0.delete(entity);
    }

    return withStore(cb);
  }

  Future<StoreEntity?> get([EntityQuery? query]) async {
    Future<StoreEntity?>? cb(EntityStore store0) async {
      final entityFromDB = await store0.get(query as StoreQuery<CLEntity>?);
      if (entityFromDB == null) {
        return null;
      }
      return StoreEntity(
        entity: entityFromDB,
        store: this,
      );
    }

    return withStore(cb);
  }

  Future<List<StoreEntity>> getAll([EntityQuery? query]) async {
    Future<List<StoreEntity>> cb(EntityStore store0) async {
      final entititesFromDB =
          await store0.getAll(query as StoreQuery<CLEntity>?);
      return entititesFromDB
          .cast<CLEntity>()
          .map(
            (entityFromDB) => StoreEntity(entity: entityFromDB, store: this),
          )
          .toList();
    }

    return withStore(cb);
  }

  Future<StoreEntity?> createCollection({
    required String label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    Future<StoreEntity?> cb(EntityStore store0) async {
      final collectionInDB = await store0
          .get(EntityQuery(null, {'label': label, 'isCollection': 1}));

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

    return withStore(cb);
  }

  Future<StoreEntity?> createMedia({
    required CLMediaFile mediaFile,
    required int? parentId,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    Future<StoreEntity?> cb(EntityStore store0) async {
      final mediaInDB = await store0.get(
        EntityQuery(null, {'md5': mediaFile.md5, 'isCollection': 1}),
      );
      int? parentId0;
      if (parentId != null) {
        var parent = (await get(
          EntityQuery(null, {'id': parentId}),
        ))
            ?.data;
        if (parent == null) {
          final tempParent = await createCollection(label: tempCollectionName);
          if (tempParent != null) {
            parent = (await tempParent.dbSave())?.data;
          }
        }
        if (parent == null || parent.id == null) {
          throw Exception(
            'missing parent; unable to create default collection',
          );
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

    return withStore(cb);
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
    Future<StoreEntity> cb(EntityStore store0) async {
      if (strategy == UpdateStrategy.skip) {
        throw Exception(
          'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
        );
      }

      final entity = await store0.get(EntityQuery(null, {'id': entityId}));

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
              ?.data;
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

    return withStore(cb);
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
    Future<StoreEntity> cb(EntityStore store0) async {
      if (strategy == UpdateStrategy.skip) {
        throw Exception(
          'UpdateStrategy.skip is not allowed for updateCollectionMultiple',
        );
      }

      final entity = await store0.get(EntityQuery(null, {'id': entityId}));

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
              await store0.get(EntityQuery(null, {'parentId': parentIdValue}));
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

    return withStore(cb);
  }

  Stream<Progress> getValidMediaFiles({
    required List<CLMediaContent> contentList,
    required StoreEntity? collection,
    void Function({
      required List<StoreEntity> existingEntities,
      required List<StoreEntity> newEntities,
      required List<CLMediaContent> invalidContent,
    })? onDone,
  }) async* {
    Stream<Progress> cb(EntityStore store0) async* {
      int parentId;
      if (collection != null) {
        yield Progress(
          currentItem: 'Creating collection " ${collection.data.label}"',
          fractCompleted: 0,
        );
        final collectionInDB = await (await createCollection(
          label: collection.data.label!,
          description: () => collection.data.description,
          parentId:
              collection.parentId == null ? null : () => collection.parentId,
        ))
            ?.dbSave();

        /// A valid collection must have been created
        if (collectionInDB == null || collectionInDB.id == null) {
          throw Exception(
            'failed to create collection with label ${collection.data.label}',
          );
        }
        if (!collectionInDB.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
        parentId = collectionInDB.id!;
      } else {
        StoreEntity? defaultParent;
        final tempParent = await createCollection(label: tempCollectionName);
        if (tempParent != null) {
          defaultParent = await tempParent.dbSave();
        }

        if (defaultParent == null || defaultParent.id == null) {
          throw Exception(
            'missing parent; unable to create default collection',
          );
        }
        if (!defaultParent.isCollection) {
          throw Exception('Parent entity must be a collection.');
        }
        parentId = defaultParent.id!;
      }

      final existingEntities = <StoreEntity>[];
      final newEntities = <StoreEntity>[];
      final invalidContent = <CLMediaContent>[];

      for (final (i, mediaFile) in contentList.indexed) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        yield Progress(
          currentItem: 'processing "${mediaFile.identity}"',
          fractCompleted: (i + 1) / contentList.length,
        );

        final item = switch (mediaFile) {
          (final CLMediaFile e) => e,
          (final CLMediaURI e) =>
            await e.toMediaFile(downloadDirectory: Directory(tempFilePath!)),
          (final CLMediaUnknown e) => await CLMediaFile.fromPath(e.path),
          _ => null
        };

        if (item != null) {
          Future<bool> processSupportedMediaContent() async {
            if ([CLMediaType.image, CLMediaType.video].contains(item.type)) {
              final mediaInDB = await get(
                EntityQuery(null, {'md5': item.md5, 'isCollection': 1}),
              );
              if (mediaInDB != null) {
                existingEntities.add(mediaInDB);
                return true;
              } else {
                final newEntity = await createMedia(
                  mediaFile: item,
                  parentId: parentId,
                );
                if (newEntity != null) {
                  newEntities.add(newEntity);
                  return true;
                }
              }
            }
            return false;
          }

          if (await processSupportedMediaContent() == false) {
            invalidContent.add(mediaFile);
          }
        } else {
          invalidContent.add(mediaFile);
        }
      }
      yield const Progress(
        currentItem: 'processed all files',
        fractCompleted: 1,
      );
      onDone?.call(
        existingEntities: existingEntities,
        newEntities: newEntities,
        invalidContent: invalidContent,
      );
    }

    yield* withStoreStream(cb);
  }

  String createTempFile({required String ext}) {
    final fileBasename =
        'keep_it_temp_${DateTime.now().millisecondsSinceEpoch}';

    return '$tempFilePath/$fileBasename.$ext';
  }
}
