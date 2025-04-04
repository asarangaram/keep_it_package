import 'dart:async';
import 'dart:io';

import 'package:cl_media_info_extractor/cl_media_info_extractor.dart'
    as extractor;

import 'package:content_store/extensions/ext_cl_media.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';

import 'package:flutter/material.dart';

import 'package:keep_it_state/keep_it_state.dart';

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
    required String label, // Mandatory if isCollection
    String? description,
    int? parentId,
    UpdateStrategy strategy = UpdateStrategy.overwrite,
  }) {

    throw UnimplementedError('create');
  }

  /// Updates multiple collection entities with the provided metadata.
  ///
  /// This method allows batch updating of existing collections objects,
  /// applies the same `parentId`
  /// applying the same `description`, `parentId`, and update `strategy` to all.
  ///
  /// [entities] is the list of entities to update.
  ///   All entries must be collections and exist.
  ///   if any entity is not a collection or does not exist, an error will be thrown.
  /// [description] is the new description to apply, depending on [strategy].
  ///   * Merges (appends) the description if [strategy] is [UpdateStrategy.mergeAppend]
  ///   * Replaces the description if [strategy] is [UpdateStrategy.overwrite]
  ///   *  [UpdateStrategy.skip] is not allowed.
  /// [parentId] is the new parent collection ID to assign, if applicable.
  ///   can be null if you want to make the collection a root collection.
  /// Returns a list of updated [CLEntity] objects

  Future<List<CLEntity>> updateCollectionMultiple(
    List<CLEntity> entities, {
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    UpdateStrategy strategy = UpdateStrategy.mergeAppend,
  }) {
    

    final updated = entities
        .where((e) => e.isCollection)
        .map(
          (e) => e.copyWith(
            description: description != null
                ? () => switch (strategy) {
                      UpdateStrategy.mergeAppend =>
                        '${e.descriptionText}\n${description()}'.trim(),
                      UpdateStrategy.overwrite => description.call(),
                      UpdateStrategy.skip =>
                        throw Exception('skip not allowed'),
                    }
                : null,
            parentId: parentId,
            isDeleted: isDeleted?.call(),
            isHidden: isHidden?.call(),
          ),
        )
        .toList();
    // FIXME: Save all collections here.
    upsertMultiple(updated)
    throw UnimplementedError('create');
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
