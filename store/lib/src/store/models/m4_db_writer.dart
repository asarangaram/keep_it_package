import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/m1_app_settings.dart';

import 'm4_db_table.dart';
import 'tags_in_collection.dart';

@immutable
class DBWriter {
  DBWriter({required this.appSettings});
  final DBTable<Collection> collectionTable = DBTable<Collection>(
    table: 'Collection',
    toMap: (Collection c) => c.toMap(),
  );
  final DBTable<Tag> tagTable = DBTable<Tag>(
    table: 'Collection',
    toMap: (Tag c) => c.toMap(),
  );
  final DBTable<CLMedia> mediaTable = DBTable<CLMedia>(
    table: 'Collection',
    toMap: (CLMedia c) => c.toMap(),
  );
  final DBTable<TagCollection> tagCollectionTable = DBTable<TagCollection>(
    table: 'TagCollection',
    toMap: (TagCollection c) => c.toMap(),
  );
  final AppSettings appSettings;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    return (await collectionTable.upsert(tx, collection, appSettings))!;
  }

  Future<void> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media,
  ) async {
    await mediaTable.upsertAll(tx, media, appSettings);
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
        tags.add((await tagTable.upsert(tx, tag, appSettings))!);
      }
      await mediaTable.delete(tx, {'collection_id': collection.id.toString()});
      await tagCollectionTable.upsertAll(
        tx,
        tags
            .map(
              (e) => TagCollection(tagID: e.id!, collectionId: collection.id!),
            )
            .toList(),
        appSettings,
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