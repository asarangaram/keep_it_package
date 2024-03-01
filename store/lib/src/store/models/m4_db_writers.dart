import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/m1_app_settings.dart';
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
  );
  final DBWriter<Tag> tagTable = DBWriter<Tag>(
    table: 'Collection',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
  );
  final DBWriter<CLMedia> mediaTable = DBWriter<CLMedia>(
    table: 'Collection',
    toMap: (CLMedia obj, {required appSettings, required validate}) {
      return obj.toMap(pathPrefix: appSettings.directories.docDir.path);
    },
  );
  final DBWriter<TagCollection> tagCollectionTable = DBWriter<TagCollection>(
    table: 'TagCollection',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
  );
  final AppSettings appSettings;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    return (await collectionTable.upsert(
      tx,
      collection,
      appSettings: appSettings,
      validate: true,
    ))!;
  }

  Future<void> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media,
  ) async {
    await mediaTable.upsertAll(
      tx,
      media,
      appSettings: appSettings,
      validate: true,
    );
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
        tags.add(
          (await tagTable.upsert(
            tx,
            tag,
            appSettings: appSettings,
            validate: true,
          ))!,
        );
      }
      await mediaTable.delete(tx, {'collection_id': collection.id.toString()});
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
        .delete(tx, {'collection_id': collection.id.toString()});
    await mediaTable.delete(tx, {'collection_id': collection.id.toString()});
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
          INSERT OR REPLACE INTO TagCollection (tag_id, collection_id)
          SELECT 
              CASE 
                  WHEN tag_id = ? THEN ?
                  ELSE tag_id
              END AS new_tag_id,
              collection_id
          FROM TagCollection
          WHERE tag_id = ?
        ''',
      [id, toTag, id],
    );
    await tx.execute('DELETE FROM Tag WHERE id = ?', [id]);
  }
*/
