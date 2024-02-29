import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension TagDB on Tag {
  Tag upsert(SqliteDatabase db) {
    /* if (id != null) {
      db.execute(
        'UPDATE Tag SET label = ?, description = ? WHERE id = ? ',
        [label.trim(), description?.trim(), id],
      );
      return getById(db, id!);
    } else {
      db.execute(
        'INSERT INTO Tag (label, description) VALUES (?, ?) ',
        [label.trim(), description?.trim()],
      );
      return getById(db, db.lastInsertRowId);
    } */
    return const Tag(label: 'unknown');
  }

  void transfer(SqliteDatabase db, int toTag) {
    if (id == null) return;
    db.execute(
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
  }

  void delete(SqliteDatabase db) {
    if (id == null) return;
    db
      ..execute(
        'DELETE FROM TagCollection WHERE tag_id = ?;',
        [id],
      )
      ..execute(
        'DELETE FROM Tag WHERE id = ?',
        [id],
      );
  }
}
