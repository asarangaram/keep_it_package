import 'package:sqlite3/sqlite3.dart';

import '../models/cluster.dart';

extension ClusterDB on Cluster {
  static Cluster getById(Database db, int clusterId) {
    final Map<String, dynamic> map =
        db.select('SELECT * FROM Cluster WHERE id = ?', [clusterId]).first;
    return Cluster.fromMap(map);
  }

  static List<Cluster> getAll(Database db) {
    final res = db.select('SELECT * FROM Cluster');
    final clusters = <Cluster>[];
    for (final r in res) {
      clusters.add(Cluster.fromMap(r));
    }
    return clusters;
  }

  int upsert(Database db) {
    if (id != null) {
      db.execute(
        'UPDATE Cluster SET description = ?, WHERE id = ?',
        [description, id],
      );
    } else {
      db.execute('INSERT INTO Cluster (description) VALUES (?)', [description]);
    }
    return db.lastInsertRowId;
  }

  void delete(Database db) {
    if (id == null) return;
    db
      ..execute('DELETE FROM Item WHERE cluster_id = ?', [id])
      ..execute('DELETE FROM TagCluster WHERE cluster_id = ?', [id])
      ..execute('DELETE FROM Cluster WHERE id = ?', [id]);
  }

  static List<Cluster> getClustersForTag(Database db, int collectionId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Cluster.* FROM Cluster
      JOIN TagCluster ON Cluster.id = TagCluster.cluster_id
      WHERE TagCluster.collection_id = ?
    ''',
      [collectionId],
    );
    return maps.map(Cluster.fromMap).toList();
  }

  static void addTagToCluster(
    Database db,
    int collectionId,
    int clusterId,
  ) {
    db.execute(
      'INSERT OR IGNORE INTO TagCluster '
      '(collection_id, cluster_id) VALUES (?, ?)',
      [collectionId, clusterId],
    );
  }
}
