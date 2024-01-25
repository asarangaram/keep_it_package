import 'package:sqlite3/sqlite3.dart';

import '../models/db_queries.dart';
import '../models/item.dart';

extension ExtDBQuery on DBQueries {
  List<ItemInDB> getByCollectionID(
    Database db,
  ) {
    if (collectionID == null) {
      throw Exception('collectionID must be provided');
    }
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Item.*
      FROM Item
      JOIN Cluster ON Item.cluster_id = Cluster.id
      JOIN CollectionCluster ON Cluster.id = CollectionCluster.cluster_id
      WHERE CollectionCluster.collection_id = $collectionID
      ORDER BY Item.UPDATED_DATE DESC
      ${limit == null ? '' : " LIMIT $limit"}
    ''',
    );

    return maps.map(ItemInDB.fromMap).toList();
  }
}
