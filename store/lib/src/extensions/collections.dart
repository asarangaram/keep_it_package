import 'package:sqlite3/sqlite3.dart';

import '../models/collection.dart';

extension CollectionDB on Collection {
  static getById(Database db, int collectionId) {
    final map = db
        .select('SELECT * FROM Collections WHERE id = ?', [collectionId]).first;
    return Collection.fromMap(map);
  }

  static List<Collection> getAll(Database db) {
    List<Map<String, dynamic>> maps = db.select('SELECT * FROM Collections');
    return maps.map((e) => Collection.fromMap(e)).toList();
  }

  int upsert(Database db) {
    if (id != null) {
      db.execute(
          'UPDATE Collections SET label = ?, description = ? WHERE id = ?',
          [label, description, id!]);
    } else {
      db.execute('INSERT INTO Collections (label, description) VALUES (?, ?)',
          [label, description]);
    }
    return db.lastInsertRowId;
  }

  void delete(Database db, {int? alternateCollectionId}) {
    if (id == null) return;

    if (alternateCollectionId != null) {
      db.execute("""
INSERT OR REPLACE INTO CollectionCluster (collection_id, cluster_id)
SELECT 
    CASE 
        WHEN collection_id = ? THEN ?
        ELSE collection_id
    END AS new_collection_id,
    cluster_id
FROM CollectionCluster
WHERE collection_id = ?
""", [id!, alternateCollectionId, id!]);
    } else {
      db.execute(
          "DELETE FROM CollectionCluster WHERE collection_id = ?;", [id!]);
    }

    if (db.select("SELECT * FROM CollectionCluster WHERE collection_id = ?;",
        [id!]).isNotEmpty) {
      throw Exception("${id!} is still used! Check implementation");
    }

    db.execute('DELETE FROM Collections WHERE id = ?', [id!]);
  }

  static List<Collection> getCollectionsForCluster(Database db, int clusterId) {
    final List<Map<String, dynamic>> maps = db.select('''
      SELECT Collections.* FROM Collections
      JOIN CollectionCluster ON Collections.id = CollectionCluster.collection_id
      WHERE CollectionCluster.cluster_id = ?
    ''', [clusterId]);
    return maps.map((e) => Collection.fromMap(e)).toList();
  }

  static List<Collection> getCollectionsForItem(Database db, int itemId) {
    final List<Map<String, dynamic>> maps = db.select('''
      SELECT Collections.* FROM Collections
      JOIN CollectionCluster ON Collections.id = CollectionCluster.collection_id
      JOIN Item ON CollectionCluster.cluster_id = Item.cluster_id
      WHERE Item.id = ?
    ''', [itemId]);
    return maps.map((e) => Collection.fromMap(e)).toList();
  }
}
