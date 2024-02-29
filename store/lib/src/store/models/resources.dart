/* import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:store/src/store/models/device_directories.dart';

@immutable
class Resources {
  const Resources({
    required this.directories,
    this.validate = true,
  });

  final DeviceDirectories directories;
  final bool validate;

  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async =>
      null;
  //TODO:
  /* CLMediaDB.getByMD5(
        db,
        md5String,
        pathPrefix: directories.docDir.path,
      ); */
}

extension ExtDeleteOnResources on Resources {
  Future<void> deleteMedia(CLMedia item) async {
    /* if (validate) {
      if (item.id == null || item.collectionId == null) {
        throw Exception(
          'Failed: deleteMedia: id = ${item.id}, '
          'collectionId: ${item.collectionId}',
        );
      }
    }
    item
      ..deleteFile()
      ..delete(db); */
  }

  Future<void> deleteCollection(Collection collection) async {
    /* if (validate) {
      if (collection.id == null) {
        throw Exception(
          'Failed: deleteCollection: id = ${collection.id}',
        );
      }
    }
    collection
      ..deleteDir(directories.docDir.path)
      ..delete(db); */
  }

  Future<void> deleteMediaMultiple(List<CLMedia> items) async {
    /* for (var i = 0; i < items.length; i++) {
      final item = items[i];
      await deleteMedia(item);
    } */
  }

  Future<void> deleteCollectionMultiple(List<Collection> collections) async {
    /* for (final collection in collections) {
      await deleteCollection(collection);
    } */
  }
}

extension ExtUpsertOnResources on Resources {
  Future<void> addMedia(Collection collection, List<CLMedia> media) async {
    /* final updated = await collection.addMedia(
      media: media,
      pathPrefix: directories.docDir.path,
    );
    if (updated != null) {
      collection.addMediaDB(
        updated,
        db: db,
        pathPrefix: directories.docDir.path,
      );
    } */
  }

  void upsertCollection(Collection collection, List<Tag>? tags) {
    /*  return collection.upsert(db)..replaceTags(db, tags); */
  }

  Stream<Progress> upsertCollectionWithMedia(
    Collection collection,
    List<Tag>? newTagsListToReplace,
    List<CLMedia> media,
    void Function() onDone,
  ) async* {
    /*  final collectionUpdated =
    collection.upsert(db)..replaceTags(db, newTagsListToReplace)
        
    final stream = collectionUpdated.addMediaWithProgress(
      media: media,
      pathPrefix: directories.docDir.path,
      onDone: (updated) {
        collectionUpdated.addMediaDB(
          updated,
          pathPrefix: directories.docDir.path,
          db: db,
        );
        onDone();
      },
    );
    await for (final item in stream) {
      yield item;
    } */
  }
}
 */
