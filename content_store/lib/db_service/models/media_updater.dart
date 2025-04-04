import 'dart:async';
import 'dart:io';

import 'package:cl_media_info_extractor/cl_media_info_extractor.dart'
    as extractor;

import 'package:content_store/extensions/ext_cl_media.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';

import 'gallery_pin.dart';
import 'share_files.dart';

enum UpdateStrategy {
  skip,
  overwrite,
  mergeAppend,
}

abstract class EntityUpdater {}

class MediaUpdater {
  MediaUpdater({
    required this.store,
    required this.directories,
    required this.albumManager,
    required this.tempCollectionName,
  });
  Store store;
  CLDirectories directories;
  final AlbumManager albumManager;

  final String tempCollectionName;

  Future<CLEntity?> getEntity({int? id, String? md5, String? label}) async =>
      store.reader.getEntity(id: id, md5: md5, label: label);
  Future<CLEntity?> upsertEntity(CLEntity entity) async =>
      store.upsertMedia(entity);
  Future<void> deleteMedia(CLEntity entity) async => deleteMedia(entity);

  // This should not be in this way.
  Future<bool?> share(
    BuildContext context,
    List<CLEntity> media,
  ) {
    final files = media
        .where((e) => !e.isCollection)
        .map(directories.getMediaAbsolutePath)
        .where((e) => File(e).existsSync());
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      files.toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<CLEntity?> upsertCollection({
    required String label,
    String? description,
    int? parentId,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) async {
    // FIXME: How to ensure this searches only for collections?
    final collectionInDB = await getEntity(label: label);

    if (collectionInDB != null && collectionInDB.id != null) {
      if (!collectionInDB.isCollection) {
        throw Exception(
          'Entity with label $label is not a collection.',
        );
      }
      if (strategy == UpdateStrategy.skip) {
        return collectionInDB;
      } else {
        return (await updateCollectionMultiple(
          [collectionInDB.id!],
          description: () => description,
          parentId: () => parentId,
          strategy: strategy,
        ))[0];
      }
    }
    throw UnimplementedError('create');
  }

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
    final entities0 = await Future.wait(entityIds.map((e) => getEntity(id: e)));
    if (entities0.any((e) => e == null)) {
      throw Exception('One or more entities do not exist.');
    }
    if (entities0.any((e) => e!.isCollection == false)) {
      throw Exception(
        'All entities must be collections. One or more entities are not collections.',
      );
    }
    if (parentId != null) {
      final parentIdValue = parentId.call();
      if (parentIdValue != null && parentIdValue <= 0) {
        throw Exception('Invalid parent ID provided.');
      }
      if (entities0.any((e) => e!.id == parentIdValue)) {
        throw Exception(
          'Parent ID cannot be the same as any of the entity IDs.',
        );
      }
      if (parentIdValue != null) {
        final parent = await getEntity(id: parentIdValue);
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

    return upsertMultiple(updated);
  }

  /// This method allows batch updating of existing media objects,
  Future<List<CLEntity>> upsertMultiple(
    List<CLEntity> entities,
  ) async {
    throw UnimplementedError('upsertMultiple');
  }

  Future<CLEntity?> createMedia({
    required extractor.CLMediaFile mediaFile,
    required int parentId,
    String? label,
    String? description,
    UpdateStrategy strategy = UpdateStrategy.skip,
  }) {
    throw UnimplementedError('create');
  }

  Future<CLEntity?> createMediaMultiple({
    required List<extractor.CLMediaFile> mediaFiles,
    required int parentId,
    String? label,
    String? description,
    bool updateIfExists = false,
  }) {
    throw UnimplementedError('create');
  }

  Future<CLEntity?> update(
    CLEntity entity, {
    String? label,
    extractor.CLMediaFile? mediaFile, // Must be null if isCollection
    String? description,
    ValueGetter<int?>?
        parentId, // must return non null, if entity is not a collection
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
  }) {
    throw UnimplementedError('create');
  }

  String fileRelativePath(CLEntity media) => p.join(
        directories.media.relativePath,
        media.mediaFileName,
      );
  String previewRelativePath(CLEntity media) => p.join(
        directories.thumbnail.relativePath,
        media.previewFileName,
      );

  String fileAbsolutePath(CLEntity media) => p.join(
        directories.media.pathString,
        media.mediaFileName,
      );
  String previewAbsolutePath(CLEntity media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );
}
