// ignore_for_file: lines_longer_than_80_chars

import 'package:store/store.dart';

import 'm3_db_query.dart';

class Queries {
  static StoreQuery<T> getQuery<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) {
    final rawQuery = switch (query) {
      DBQueries.collections => DBQuery<Collection>.map(
          sql: 'SELECT * FROM Collection ',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.medias => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media ',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.collectionById => DBQuery<Collection>.map(
          sql: 'SELECT * FROM Collection WHERE id = ? ',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionByLabel => DBQuery<Collection>.map(
          sql: 'SELECT * FROM Collection WHERE label = ? ',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsAll => DBQuery<Collection>.map(
          sql: 'SELECT * FROM Collection '
              "WHERE label NOT LIKE '***%'",
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsExcludeEmpty => DBQuery<Collection>.map(
          sql: 'SELECT DISTINCT Collection.* FROM Collection '
              'JOIN Media ON Collection.id = Media.collectionId '
              "WHERE label NOT LIKE '***%' AND "
              'Media.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Media'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsEmpty => DBQuery<Collection>.map(
          sql: 'SELECT Collection.* FROM Collection '
              'LEFT JOIN Media ON Collection.id = Media.collectionId '
              'WHERE Media.collectionId IS NULL AND '
              "label NOT LIKE '***%' AND "
              'Media.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Media'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionByIdList => DBQuery<Collection>.map(
          sql: 'SELECT * FROM Collection WHERE id IN (?)',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.mediaById => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE id = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByServerUID => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE serverUID = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaAllIncludingAux => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE isHidden = 0 AND isDeleted = 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaDownloadPending => DBQuery<CLMedia>.map(
          sql:
              'SELECT * FROM Media WHERE serverUID IS NOT NULL AND isMediaCached = 0 AND mediaLog  IS NULL',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.previewDownloadPending => DBQuery<CLMedia>.map(
          sql:
              'SELECT * FROM Media WHERE serverUID IS NOT NULL AND isPreviewCached  = 0 AND previewLog IS NULL',
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
      DBQueries.mediaByPath => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE name = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLMedia>.map(
          sql: 'SELECT * FROM Media WHERE id IN (?)',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByNoteID => DBQuery<CLMedia>.map(
          sql:
              'SELECT Media.* FROM Media JOIN MediaNote ON Media.id = MediaNote.mediaId WHERE MediaNote.noteId = ?;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.notesByMediaId => DBQuery<CLMedia>.map(
          sql:
              'SELECT Media.* FROM Media JOIN MediaNote ON Media.id = MediaNote.noteId WHERE MediaNote.mediaId = ?;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.notesAll => DBQuery<CLMedia>.map(
          sql:
              'SELECT Media.* FROM Media WHERE id IN (SELECT noteId FROM MediaNote);',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.notesOrphan => DBQuery<CLMedia>.map(
          sql:
              'SELECT Media.* FROM Media WHERE isAux = 1 AND id NOT IN (SELECT noteId FROM MediaNote);',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.serverUIDAll => DBQuery<CLMedia>.map(
          sql: 'SELECT *  FROM Media  WHERE serverUID IS NOT NULL;',
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

/*

find media with serverUID:

  SELECT Media.* 
  FROM Media
  JOIN MediaLocalInfo ON Media.id = MediaLocalInfo.id
  WHERE MediaLocalInfo.serverUID = ?;

find if the media is from server or not.
  SELECT COUNT(*)
  FROM MediaLocalInfo
  WHERE id = ?;

get MediaID
  SELECT id 
  FROM MediaLocalInfo 
  WHERE serverUID = ?;
  
*/
