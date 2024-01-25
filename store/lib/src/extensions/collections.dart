import 'package:sqlite3/sqlite3.dart';

import '../models/collection.dart';

extension TagDB on Tag {
  static Tag getById(Database db, int collectionId) {
    final map = db.select(
      'SELECT * FROM Tag WHERE id = ? ' 'ORDER BY LOWER(label) ASC',
      [collectionId],
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
          INSERT OR REPLACE INTO TagCluster (collection_id, cluster_id)
          SELECT 
              CASE 
                  WHEN collection_id = ? THEN ?
                  ELSE collection_id
              END AS new_collection_id,
              cluster_id
          FROM TagCluster
          WHERE collection_id = ?
        ''',
        [id, alternateTagId, id],
      );
    } else {
      db.execute(
        'DELETE FROM TagCluster WHERE collection_id = ?;',
        [id],
      );
    }

    if (db.select(
      'SELECT * FROM TagCluster WHERE collection_id = ?;',
      [id],
    ).isNotEmpty) {
      throw Exception('${id!} is still used! Check implementation');
    }

    db.execute('DELETE FROM Tag WHERE id = ?', [id]);
  }

  static List<Tag> getTagsForCluster(Database db, int clusterId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCluster ON Tag.id = TagCluster.collection_id
      WHERE TagCluster.cluster_id = ?
    ''',
      [clusterId],
    );
    return maps.map(Tag.fromMap).toList();
  }

  static List<Tag> getTagsForItem(Database db, int itemId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Tag.* FROM Tag
      JOIN TagCluster ON Tag.id = TagCluster.collection_id
      JOIN Item ON TagCluster.cluster_id = Item.cluster_id
      WHERE Item.id = ?
    ''',
      [itemId],
    );
    return maps.map(Tag.fromMap).toList();
  }
}
