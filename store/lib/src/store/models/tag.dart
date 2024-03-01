import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension TagDB on Tag {
  Future<void> deleteTag(SqliteWriteContext tx) async {
    await tx.execute(
      'DELETE FROM TagCollection WHERE tag_id = ?;',
      [id],
    );
    await tx.execute('DELETE FROM Tag WHERE id = ?');
  }

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
}

const restrictUsage = true;
