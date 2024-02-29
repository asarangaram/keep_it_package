import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm3_db_queries.dart';
import 'm3_db_query.dart';

extension CollectionDB on Collection {
  Future<void> upsert(SqliteWriteContext tx) async {
    if (id != null) {
      await tx.execute(
        'UPDATE Collection SET label = ? , description = ?  WHERE id = ?',
        [label.trim(), description?.trim(), id],
      );
    } else {
      await tx.execute(
        'INSERT INTO Collection (label, description) VALUES (?, ?) ',
        [label.trim(), description?.trim()],
      );
    }
  }

  Future<void> deleteCollection(SqliteWriteContext tx) async {
    if (id == null) return;
    await tx.execute(
      'DELETE FROM TagCollection WHERE collection_id = ?',
      [id],
    );
    await tx.execute(
      'DELETE FROM Collection WHERE id = ?',
      [id],
    );
    await tx.execute(
      'DELETE FROM Item WHERE collection_id = ?',
      [id],
    );
  }

  Future<void> addTag(SqliteWriteContext tx, int tagId) async {
    if (id != null) {
      await tx.execute(
        'INSERT INTO TagCollection '
        '(tag_id, collection_id) VALUES (?, ?)',
        [tagId, id],
      );
    }
  }

  Future<void> addTags(SqliteWriteContext tx, List<int> tagIds) async {
    if (id != null) {
      await tx.executeBatch(
        'INSERT INTO TagCollection '
        '(tag_id, collection_id) VALUES (?, ?)',
        [
          for (final tagId in tagIds) [tagId, id],
        ],
      );
    }
  }

  Future<void> removeTag(SqliteWriteContext tx, int tagId) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [tagId, id],
      );
    }
  }

  Future<void> removeTags(SqliteWriteContext tx, List<int> tagIds) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [
          for (final tagId in tagIds) [tagId, id],
        ],
      );
    }
  }

  Future<void> removeAllTags(SqliteWriteContext tx) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [id],
      );
    }
  }

  Future<void> replaceTags(SqliteWriteContext tx, List<int> tagIds) async {
    await removeAllTags(tx);
    await addTags(tx, tagIds);
  }

  /* Future<(List<int>?, List<int>?)> splitTags(
    SqliteDatabase db,
    List<int>? tagIds,
  ) async {
    List<int>? tagsIdsToAdd;
    List<int>? tagIdsToRemove;
    if (tagIds == null) return (null, null);
    if (id == null) return (tagIds, null);

    final existingTagIds =
        (await (DBQueries.tagsByCollectionID.sql as DBQuery<Tag>)
                .copyWith(parameters: [id]).readMultiple(db))
            .map((e) => e.id!);
    tagsIdsToAdd = tagIds
        .where(
          (updated) => !existingTagIds.any((existing) => existing == updated),
        )
        .toList();

    tagIdsToRemove = existingTagIds
        .where(
          (existing) => !tagIds.any((updated) => updated == existing),
        )
        .toList();
    return (tagsIdsToAdd, tagIdsToRemove);
  } */
}
