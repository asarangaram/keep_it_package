import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/m2_db_manager.dart';
import 'package:store/store.dart';



extension CollectionDB on Collection {
  Future<void> upsertCollection(SqliteWriteContext tx) async {
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
        'WHERE collection_id = ? ',
        [id],
      );
    }
  }

  Future<void> replaceTags(SqliteWriteContext tx, List<int> tagIds) async {
    await removeAllTags(tx);
    await addTags(tx, tagIds);
  }

  Future<void> upsertMedia(SqliteWriteContext tx, List<CLMedia> media) async {
    final newMedia = media.where((e) => e.id == null);
    if (newMedia.isNotEmpty) {
      await tx.executeBatch(
        'INSERT  INTO Item (path, '
        'ref, collection_id, type, originalDate, md5String) '
        'VALUES (?, ?, ?, ?, ?, ?) ',
        [
          for (final m in newMedia)
            [
              m.path,
              m.ref,
              m.collectionId,
              m.type.name,
              m.originalDate?.toSQL(),
              m.md5String,
            ],
        ],
      );
    }
  }
}

bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
