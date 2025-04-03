import 'package:store/store.dart';

import 'm3_db_query.dart';

class Queries {
  static StoreQuery<T> getQuery<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) {
    final rawQuery = switch (query) {
      DBQueries.mediaById => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE id = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByMD5 => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE md5String = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByLabel => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE label = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.entitiesVisible => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByCollectionId => DBQuery<CLEntity>.map(
          sql:
              'SELECT * FROM Media WHERE collectionId = ? AND isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE id IN (?)',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaPinned => DBQuery<CLEntity>.map(
          sql:
              "SELECT * FROM Media WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden = 0 AND isDeleted = 0",
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaStaled => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE isHidden <> 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaDeleted => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE isDeleted <> 0 ',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
    };
    if (parameters == null) {
      return rawQuery as StoreQuery<T>;
    } else {
      return rawQuery.insertParameters(parameters) as StoreQuery<T>;
    }
  }
}
