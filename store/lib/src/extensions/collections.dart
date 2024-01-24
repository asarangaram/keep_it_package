import 'package:sqlite3/sqlite3.dart';

import '../models/collection.dart';

extension CollectionDB on Collection {
  static Collection getById(Database db, int collectionId) {
    final map = db.select(
      'SELECT * FROM Collection WHERE id = ? ' 'ORDER BY LOWER(label) ASC',
      [collectionId],
    ).first;
    return Collection.fromMap(map);
  }

  static List<Collection> getAll(Database db) {
    final List<Map<String, dynamic>> maps = db.select(
      'SELECT * FROM Collection ' 'ORDER BY LOWER(label) ASC',
    );
    return maps.map(Collection.fromMap).toList();
  }

  int upsert(Database db) {
    print('id updated $id');
    if (id != null) {
      db.execute(
        'UPDATE Collection SET label = ?, description = ? WHERE id = ? ',
        [label, description, id],
      );
      return id!;
    } else {
      db.execute(
        'INSERT INTO Collection (label, description) VALUES (?, ?) ',
        [label, description],
      );
      return db.lastInsertRowId;
    }
  }

  void delete(Database db, {int? alternateCollectionId}) {
    if (id == null) return;

    if (alternateCollectionId != null) {
      db.execute(
        '''
INSERT OR REPLACE INTO CollectionCluster (collection_id, cluster_id)
SELECT 
    CASE 
        WHEN collection_id = ? THEN ?
        ELSE collection_id
    END AS new_collection_id,
    cluster_id
FROM CollectionCluster
WHERE collection_id = ?
''',
        [id, alternateCollectionId, id],
      );
    } else {
      db.execute(
        'DELETE FROM CollectionCluster WHERE collection_id = ?;',
        [id],
      );
    }

    if (db.select(
      'SELECT * FROM CollectionCluster WHERE collection_id = ?;',
      [id],
    ).isNotEmpty) {
      throw Exception('${id!} is still used! Check implementation');
    }

    db.execute('DELETE FROM Collection WHERE id = ?', [id]);
  }

  static List<Collection> getCollectionsForCluster(Database db, int clusterId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Collection.* FROM Collection
      JOIN CollectionCluster ON Collection.id = CollectionCluster.collection_id
      WHERE CollectionCluster.cluster_id = ?
    ''',
      [clusterId],
    );
    return maps.map(Collection.fromMap).toList();
  }

  static List<Collection> getCollectionsForItem(Database db, int itemId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Collection.* FROM Collection
      JOIN CollectionCluster ON Collection.id = CollectionCluster.collection_id
      JOIN Item ON CollectionCluster.cluster_id = Item.cluster_id
      WHERE Item.id = ?
    ''',
      [itemId],
    );
    return maps.map(Collection.fromMap).toList();
  }
}
