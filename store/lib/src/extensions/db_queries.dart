import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/db_queries.dart';

extension ExtDBQuery on DBQueries {
  List<CLMedia> getByTagID(
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
      ORDER BY Item.updatedDate DESC
    ''',
    );

    return maps.map(CLMedia.fromMap).toList();
  }
}
