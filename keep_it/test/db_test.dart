import 'package:flutter_test/flutter_test.dart';
import 'package:keep_it/db/db.dart';

import 'package:keep_it/models/cluster.dart';
import 'package:keep_it/models/collection.dart';
import 'package:keep_it/models/item.dart';

void main() {
  test('test database', () {
    // Compare the actual result with the expected value
    expect(DBTest.dbTest1(), true);
  });
}

class DBTest {
  static bool dbTest1() {
    final DatabaseManager dbManager = DatabaseManager();
    var db = dbManager.db;

    final List<int> collectionIds = [];
    final List<int> clusterIds = [];
    final List<int> itemIds = [];

    // Insert data
    for (var i = 0; i < 3; i++) {
      collectionIds.add(Collection(
              label: 'Collection$i', description: 'Collection$i Description')
          .upsert(db));
    }
    for (var i = 0; i < 2; i++) {
      clusterIds.add(Cluster(description: 'Cluster$i Description').upsert(db));
    }

    for (var i = 0; i < 6; i++) {
      itemIds.add(Item(
              path: '/path/to/item$i',
              ref: i == 5 ? "ref5" : null,
              clusterId: clusterIds[i & 1])
          .upsert(db));
    }

    ClusterDB.addCollectionToCluster(db, collectionIds[0], clusterIds[0]);
    ClusterDB.addCollectionToCluster(db, collectionIds[1], clusterIds[0]);
    ClusterDB.addCollectionToCluster(db, collectionIds[1], clusterIds[1]);
    ClusterDB.addCollectionToCluster(db, collectionIds[2], clusterIds[1]);

    // Retrieve data

    final collections = CollectionDB.getAll(db);

    collections[0].label = "New Label";
    collections[0].upsert(db);
    for (var collection in collections) {
      final clusters = ClusterDB.getClustersForCollection(db, collection.id!);
      for (var cluster in clusters) {
        CollectionDB.getCollectionsForCluster(db, cluster.id!);
        ItemDB.getItemsForCluster(db, cluster.id!);
      }
    }
    collections[2].delete(db);
    dbManager.close();

    return true;
  }
}
