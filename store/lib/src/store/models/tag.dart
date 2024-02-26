import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite3/sqlite3.dart';

extension TagDB on Tag {
  static Tag getById(Database db, int id) {
    final map = db.select(
      'SELECT * FROM Tag WHERE id = ? ' 'ORDER BY LOWER(label) ASC',
      [id],
    ).first;
    return Tag.fromMap(map);
  }

  static List<Tag> getAll(Database db, {bool includeEmpty = true}) {
    final ResultSet maps;
    if (includeEmpty) {
      maps = db.select(
        'SELECT * FROM Tag ' 'ORDER BY LOWER(label) ASC',
      );
    } else {
      maps = db.select(
        '''
          SELECT DISTINCT Tag.*
          FROM Tag
          JOIN TagCollection ON Tag.id = TagCollection.tag_id
          JOIN Collection ON TagCollection.collection_id = Collection.id
          JOIN Item ON Collection.id = Item.collection_id;
          ''',
      );
    }
    return maps.map(Tag.fromMap).toList();
  }

  Tag upsert(Database db) {
    if (id != null) {
      db.execute(
        'UPDATE Tag SET label = ?, description = ? WHERE id = ? ',
        [label, description, id],
      );
      return getById(db, id!);
    } else {
      db.execute(
        'INSERT INTO Tag (label, description) VALUES (?, ?) ',
        [label, description],
      );
      return getById(db, db.lastInsertRowId);
    }
  }

  void transfer(Database db, int toTag) {
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

  void delete(Database db) {
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

  static List<Tag> getByCollectionId(Database db, int id) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCollection ON Tag.id = TagCollection.tag_id
      WHERE TagCollection.collection_id = ?
    ''',
      [id],
    );
    return maps.map(Tag.fromMap).toList();
  }

  static List<Tag> getByCLMediaId(Database db, int id) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCollection ON Tag.id = TagCollection.tag_id
      JOIN Item ON TagCollection.collection_id = Item.collection_id
      WHERE Item.id = ?
    ''',
      [id],
    );
    return maps.map(Tag.fromMap).toList();
  }
}
