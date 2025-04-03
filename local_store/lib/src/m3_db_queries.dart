import 'package:store/store.dart';

import 'm3_db_query.dart';

class Queries {
  static StoreQuery<T> getQuery<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) {
    final rawQuery = switch (query) {
      DBQueries.medias => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media ',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaById => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE id = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaAllIncludingAux => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaAll => DBQuery<CLEntity>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByCollectionId => DBQuery<CLEntity>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND collectionId = ? AND isHidden = 0 AND isDeleted = 0',
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
      DBQueries.mediaPinned => DBQuery<CLEntity>.map(
          sql:
              "SELECT * FROM Media WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden = 0 AND isDeleted = 0",
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaStaled => DBQuery<CLEntity>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND  isHidden <> 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaDeleted => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE isAux = 0 AND  isDeleted <> 0 ',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE id IN (?)',
          triggerOnTables: const {'Media'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.mediaOnDevice => DBQuery<CLEntity>.map(
          sql:
              'SELECT DISTINCT m.* FROM Media m JOIN Collection c ON m.collectionId = c.id WHERE c.serverUID IS NOT NULL;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLEntity.fromMap,
        ),
      DBQueries.localMediaAll => DBQuery<CLEntity>.map(
          sql: 'SELECT * FROM Media WHERE serverUID IS NULL AND isDeleted = 0',
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
