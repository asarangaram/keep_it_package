import 'package:sqlite3/sqlite3.dart';

import '../models/db_queries.dart';
import '../models/item.dart';

extension ExtDBQuery on DBQueries {
  List<ItemInDB> getByTagID(
    Database db,
  ) {
    if (tagID == null) {
      throw Exception('tagID must be provided');
    }
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Item.*
      FROM Item
      JOIN Collection ON Item.collection_id = Collection.id
      JOIN TagCollection ON Collection.id = TagCollection.collection_id
      WHERE TagCollection.tag_id = $tagID
      ORDER BY Item.UPDATED_DATE DESC
    ''',
    );

    return maps.map(ItemInDB.fromMap).toList();
  }
}
