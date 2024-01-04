import 'package:sqlite3/sqlite3.dart';

import '../models/item.dart';

extension ItemDB on ItemInDB {
  static itemGetById(Database db, int itemId) {
    final Map<String, dynamic> map =
        db.select('SELECT * FROM Item WHERE id = ?', [itemId]).first;
    return ItemInDB.fromMap(map);
  }

  static List<ItemInDB> getAll(Database db) {
    List<Map<String, dynamic>> maps = db.select('SELECT * FROM Item');
    return maps.map((e) => ItemInDB.fromMap(e)).toList();
  }

  int upsert(
    Database db,
  ) {
    if (id != null) {
      db.execute(
          'UPDATE OR IGNORE Item SET path = ?, ref = ?, cluster_id = ? type=? WHERE id = ?',
          [path, ref, clusterId, type, id!]);
    }
    db.execute(
        'INSERT OR IGNORE INTO Item (path, ref, cluster_id, type) VALUES (?, ?, ?, ?)',
        [path, ref, clusterId, type.name]);
    return db.lastInsertRowId;
  }

  void delete(Database db) {
    if (id == null) return;
    db.execute('DELETE FROM Item WHERE id = ?', [id!]);
  }

  static List<ItemInDB> getItemsForCluster(Database db, int clusterId) {
    List<Map<String, dynamic>> maps =
        db.select('SELECT * FROM Item WHERE cluster_id = ?', [clusterId]);

    return maps.map((e) => ItemInDB.fromMap(e)).toList();
  }
}
