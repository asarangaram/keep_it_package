import 'package:store/store.dart';

import 'm3_db_query.dart';

class Queries {
  static StoreQuery<T> getQuery<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) {
    final rawQuery = switch (query) {
      DBQueries.medias => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media ',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaById => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE id = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaAllIncludingAux => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaAll => DBQuery<CLMedia>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByCollectionId => DBQuery<CLMedia>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND collectionId = ? AND isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByMD5 => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE md5String = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByLabel => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE label = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaPinned => DBQuery<CLMedia>.map(
          sql:
              "SELECT * FROM Media WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden = 0 AND isDeleted = 0",
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaStaled => DBQuery<CLMedia>.map(
          sql:
              'SELECT * FROM Media WHERE isAux = 0 AND  isHidden <> 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaDeleted => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE isAux = 0 AND  isDeleted <> 0 ',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE id IN (?)',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaOnDevice => DBQuery<CLMedia>.map(
          sql:
              'SELECT DISTINCT m.* FROM Media m JOIN Collection c ON m.collectionId = c.id WHERE c.serverUID IS NOT NULL;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.localMediaAll => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE serverUID IS NULL AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
    };
    if (parameters == null) {
      return rawQuery as StoreQuery<T>;
    } else {
      return rawQuery.insertParameters(parameters) as StoreQuery<T>;
    }
  }
}
