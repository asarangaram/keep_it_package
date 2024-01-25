import 'package:sqlite3/sqlite3.dart';

import '../models/tag.dart';

extension TagDB on Tag {
  static Tag getById(Database db, int tagId) {
    final map = db.select(
      'SELECT * FROM Tag WHERE id = ? ' 'ORDER BY LOWER(label) ASC',
      [tagId],
    ).first;
    return Tag.fromMap(map);
  }

  static List<Tag> getAll(Database db) {
    final List<Map<String, dynamic>> maps = db.select(
      'SELECT * FROM Tag ' 'ORDER BY LOWER(label) ASC',
    );
    return maps.map(Tag.fromMap).toList();
  }

  int upsert(Database db) {
    if (id != null) {
      db.execute(
        'UPDATE Tag SET label = ?, description = ? WHERE id = ? ',
        [label, description, id],
      );
      return id!;
    } else {
      db.execute(
        'INSERT INTO Tag (label, description) VALUES (?, ?) ',
        [label, description],
      );
      return db.lastInsertRowId;
    }
  }

  void delete(Database db, {int? alternateTagId}) {
    if (id == null) return;

    if (alternateTagId != null) {
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
        [id, alternateTagId, id],
      );
    } else {
      db.execute(
        'DELETE FROM TagCollection WHERE tag_id = ?;',
        [id],
      );
    }

    if (db.select(
      'SELECT * FROM TagCollection WHERE tag_id = ?;',
      [id],
    ).isNotEmpty) {
      throw Exception('${id!} is still used! Check implementation');
    }

    db.execute('DELETE FROM Tag WHERE id = ?', [id]);
  }

  static List<Tag> getTagsForCollection(Database db, int collectionId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCollection ON Tag.id = TagCollection.tag_id
      WHERE TagCollection.collection_id = ?
    ''',
      [collectionId],
    );
    return maps.map(Tag.fromMap).toList();
  }

  static List<Tag> getTagsForItem(Database db, int itemId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCollection ON Tag.id = TagCollection.tag_id
      JOIN Item ON TagCollection.collection_id = Item.collection_id
      WHERE Item.id = ?
    ''',
      [itemId],
    );
    return maps.map(Tag.fromMap).toList();
  }
}
