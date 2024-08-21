// ignore_for_file: lines_longer_than_80_chars

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'backup_query.dart';
import 'm3_db_query.dart';

class DBReader {
  DBReader(this.tx);
  SqliteWriteContext tx;

  Future<T?> read<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).read(tx);
  }

  Future<List<T>> readMultiple<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).readMultiple(tx);
  }

  Future<List<Object?>?> getDBRecords() async {
    final dbArchive =
        (await tx.getAll(backupQuery, [])).rows.map((e) => e[0]).toList();

    return dbArchive;
  }

  Future<Collection?> getCollectionByID(
    int id,
  ) async {
    return read<Collection>(
      getQuery(DBQueries.collectionById, parameters: [id])
          as DBQuery<Collection>,
    );
  }

  Future<CLMedia?> getMediaByID(
    int id,
  ) {
    return read<CLMedia>(
      getQuery(DBQueries.mediaById, parameters: [id]) as DBQuery<CLMedia>,
    );
  }

  Future<List<Collection>> getCollectionsByIDList(
    List<int> idList,
  ) {
    return readMultiple<Collection>(
      getQuery(
        DBQueries.collectionByIdList,
        parameters: ['(${idList.join(', ')})'],
      ) as DBQuery<Collection>,
    );
  }

  Future<List<CLMedia>> getMediasByIDList(
    List<int> idList,
  ) {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.mediaByIdList, parameters: ['(${idList.join(', ')})'])
          as DBQuery<CLMedia>,
    );
  }

  Future<List<CLMedia>> getMediaByCollectionId(
    int collectionId,
  ) async {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.mediaByCollectionId, parameters: [collectionId])
          as DBQuery<CLMedia>,
    );
  }

  Future<List<CLMedia>?> getNotesByMediaID(
    int mediaId,
  ) {
    return readMultiple(
      getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
          as DBQuery<CLMedia>,
    );
  }

  Future<List<CLMedia>?> getMediaByNoteID(
    int noteId,
  ) async {
    return readMultiple(
      getQuery(DBQueries.mediaByNoteID, parameters: [noteId])
          as DBQuery<CLMedia>,
    );
  }

  Future<List<Collection>?> getCollectionAll() async {
    return readMultiple<Collection>(
      getQuery(DBQueries.collectionsAll) as DBQuery<Collection>,
    );
  }

  Future<List<CLMedia>> getMediaAll() {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.mediaAll) as DBQuery<CLMedia>,
    );
  }

  Future<List<CLMedia>> getNotesAll() {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.notesAll) as DBQuery<CLMedia>,
    );
  }

  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters}) {
    final rawQuery = switch (query) {
      DBQueries.collectionById => DBQuery<Collection>(
          sql: 'SELECT * FROM Collection WHERE id = ? ',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionByLabel => DBQuery<Collection>(
          sql: 'SELECT * FROM Collection WHERE label = ? ',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsAll => DBQuery<Collection>(
          sql: 'SELECT * FROM Collection '
              "WHERE label NOT LIKE '***%'",
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsExcludeEmpty => DBQuery<Collection>(
          sql: 'SELECT DISTINCT Collection.* FROM Collection '
              'JOIN Media ON Collection.id = Media.collectionId '
              "WHERE label NOT LIKE '***%' AND "
              'Media.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Media'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsEmpty => DBQuery<Collection>(
          sql: 'SELECT Collection.* FROM Collection '
              'LEFT JOIN Media ON Collection.id = Media.collectionId '
              'WHERE Media.collectionId IS NULL AND '
              "label NOT LIKE '***%' AND "
              'Media.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Media'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionByIdList => DBQuery<Collection>(
          sql: 'SELECT * FROM Collection WHERE id IN (?)',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.mediaById => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE id = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaAll => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE isHidden IS 0 AND isDeleted IS 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByCollectionId => DBQuery<CLMedia>(
          sql:
              'SELECT * FROM Media WHERE collectionId = ? AND isHidden IS 0 AND isDeleted IS 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByMD5 => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE md5String = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaPinned => DBQuery<CLMedia>(
          sql:
              "SELECT * FROM Media WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden IS 0 AND isDeleted IS 0",
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaStaled => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE isHidden IS NOT 0 AND isDeleted IS 0',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaDeleted => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE isDeleted IS NOT 0 ',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByPath => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE path = ?',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE id IN (?)',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByNoteID => DBQuery<CLMedia>(
          sql:
              'SELECT Media.* FROM Media JOIN MediaNote ON Media.id = MediaNote.itemId WHERE MediaNote.noteId = ?;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.notesByMediaId => DBQuery<CLMedia>(
          sql:
              'SELECT Media.* FROM Media JOIN MediaNote ON Media.id = MediaNote.noteId WHERE MediaNote.itemId = ?;',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      // FIXME - Look for AUX
      DBQueries.notesAll => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Notes',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
      // FIXME - Look for AUX
      DBQueries.notesOrphan => DBQuery<CLMedia>(
          sql:
              'SELECT n.* FROM Notes n LEFT JOIN MediaNote inote ON n.id = inote.noteId WHERE inote.noteId IS NULL',
          triggerOnTables: const {'Media', 'MediaNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.collectionLocallyModified => DBQuery<Collection>(
          sql: 'SELECT * FROM Collection WHERE locallyModified = True;',
          triggerOnTables: const {'Collection'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.mediaLocallyModified => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Media WHERE locallyModified = True;',
          triggerOnTables: const {'Media'},
          fromMap: CLMedia.fromMap,
        ),
    };
    if (parameters == null) {
      return rawQuery as StoreQuery<T>;
    } else {
      return rawQuery.copyWith(parameters: parameters) as StoreQuery<T>;
    }
  }

  Future<List<Collection>> locallyModifiedCollections() {
    return readMultiple<Collection>(
      getQuery(
        DBQueries.collectionLocallyModified,
      ) as DBQuery<Collection>,
    );
  }

  Future<List<CLMedia>> locallyModifiedMedias() {
    return readMultiple<CLMedia>(
      getQuery(
        DBQueries.mediaLocallyModified,
      ) as DBQuery<CLMedia>,
    );
  }
}
