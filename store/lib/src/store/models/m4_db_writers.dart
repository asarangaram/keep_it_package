import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/m3_db_reader.dart';

import '../models/m1_app_settings.dart';
import 'm3_db_readers.dart';
import 'm4_db_writer.dart';
import 'tags_in_collection.dart';

@immutable
class DBWriters {
  DBWriters({required this.appSettings});
  final DBWriter<Collection> collectionTable = DBWriter<Collection>(
    table: 'Collection',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
    readBack: (
      tx,
      collection, {
      required appSettings,
      required validate,
    }) async {
      return (DBReaders.collectionByLabel.sql as DBReader<Collection>)
          .copyWith(parameters: [collection.label]).read(
        tx,
        appSettings: appSettings,
        validate: validate,
      );
    },
  );
  final DBWriter<Tag> tagTable = DBWriter<Tag>(
    table: 'Tag',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
    readBack: (tx, tag, {required appSettings, required validate}) {
      return (DBReaders.tagByLabel.sql as DBReader<Tag>)
          .copyWith(parameters: [tag.label]).read(
        tx,
        appSettings: appSettings,
        validate: validate,
      );
    },
  );
  final DBWriter<CLMedia> mediaTable = DBWriter<CLMedia>(
    table: 'Item',
    toMap: (CLMedia obj, {required appSettings, required validate}) {
      return obj.toMap(pathPrefix: appSettings.directories.docDir.path);
    },
    readBack: null,
  );
  final DBWriter<TagCollection> tagCollectionTable = DBWriter<TagCollection>(
    table: 'TagCollection',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
    readBack: null,
  );
  final AppSettings appSettings;

  Future<Tag> upsertTag(
    SqliteWriteContext tx,
    Tag tag,
  ) async {
    _infoLogger('upsertTag: $tag');
    final updated = await tagTable.upsert(
      tx,
      tag,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertTag: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Tag',
      );
    }
    return updated!;
  }

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    _infoLogger('upsertCollection: $collection');
    final updated = await collectionTable.upsert(
      tx,
      collection,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertCollection: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Collection',
      );
    }
    return updated!;
  }

  Future<List<CLMedia?>> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media,
  ) async {
    _infoLogger('upsertMediaMultiple: $media');
    final updated = await mediaTable.upsertAll(
      tx,
      media,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertMediaMultiple: Done :  $updated');
    // TODO(anandas): : implemetn readback and introduce Exception here
    return updated;
  }

  Future<void> replaceTags(
    SqliteWriteContext tx,
    Collection collection,
    List<Tag>? newTagsListToReplace,
  ) async {
    if (newTagsListToReplace?.isNotEmpty ?? false) {
      final newTags = newTagsListToReplace!.where((e) => e.id == null).toList();
      final tags = newTagsListToReplace.where((e) => e.id != null).toList();

      for (final tag in newTags) {
        tags.add(await upsertTag(tx, tag));
      }
      await tagCollectionTable
          .delete(tx, {'collectionId': collection.id.toString()});
      await tagCollectionTable.upsertAll(
        tx,
        tags
            .map(
              (e) => TagCollection(tagID: e.id!, collectionId: collection.id!),
            )
            .toList(),
        appSettings: appSettings,
        validate: true,
      );
    }
  }

  Future<void> deleteCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    await tagCollectionTable
        .delete(tx, {'collectionId': collection.id.toString()});
    await mediaTable.delete(tx, {'collectionId': collection.id.toString()});
    await collectionTable.delete(tx, {'id': collection.id.toString()});
  }

  Future<void> deleteMedia(
    SqliteWriteContext tx,
    CLMedia media,
  ) async {
    await mediaTable.delete(tx, {'id': media.id.toString()});
  }
}

/*
Future<void> mergeTag(SqliteWriteContext tx, int toTag) async {
    await tx.execute(
      '''
          INSERT OR REPLACE INTO TagCollection (tagId, collectionId)
          SELECT 
              CASE 
                  WHEN tagId = ? THEN ?
                  ELSE tagId
              END AS new_tagId,
              collectionId
          FROM TagCollection
          WHERE tagId = ?
        ''',
      [id, toTag, id],
    );
    await tx.execute('DELETE FROM Tag WHERE id = ?', [id]);
  }
*/

const _filePrefix = 'DB Write: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
