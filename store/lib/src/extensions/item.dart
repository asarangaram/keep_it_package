import 'package:sqlite3/sqlite3.dart';

import '../models/item.dart';

extension ItemDB on Item {
  static itemGetById(Database db, int itemId) {
    final Map<String, dynamic> map =
        db.select('SELECT * FROM Item WHERE id = ?', [itemId]).first;
    return Item.fromMap(map);
  }

  static List<Item> getAll(Database db) {
    List<Map<String, dynamic>> maps = db.select('SELECT * FROM Item');
    return maps.map((e) => Item.fromMap(e)).toList();
  }

  int upsert(
    Database db,
  ) {
    if (id != null) {
      db.execute(
          'UPDATE OR IGNORE Item SET path = ?, ref = ?, cluster_id = ? WHERE id = ?',
          [path, ref, clusterId, id!]);
    }
    db.execute(
        'INSERT OR IGNORE INTO Item (path, ref, cluster_id) VALUES (?, ?, ?)',
        [path, ref, clusterId]);
    return db.lastInsertRowId;
  }

  void delete(Database db) {
    if (id == null) return;
    db.execute('DELETE FROM Item WHERE id = ?', [id!]);
  }

  static List<Item> getItemsForCluster(Database db, int clusterId) {
    List<Map<String, dynamic>> maps =
        db.select('SELECT * FROM Item WHERE cluster_id = ?', [clusterId]);

    return maps.map((e) => Item.fromMap(e)).toList();
  }
}
