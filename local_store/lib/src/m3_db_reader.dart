// ignore_for_file: lines_longer_than_80_chars

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'backup_query.dart';
import 'm3_db_query.dart';

class DBReader {
  DBReader(this.db);
  final SqliteDatabase db;

  Future<T?> read<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).read(db);
  }

  Future<List<T>> readMultiple<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).readMultiple(db);
  }

  Future<List<Object?>?> getDBRecords() async {
    final dbArchive =
        (await db.getAll(backupQuery, [])).rows.map((e) => e[0]).toList();

    return dbArchive;
  }

  Future<List<CLMedia>> getMediaByCollectionId(
    SqliteWriteContext tx,
    int collectionId,
  ) async {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.mediaByCollectionId, parameters: [collectionId])
          as DBQuery<CLMedia>,
    );
  }

  Future<List<CLNote>?> getNotesByMediaID(
    int mediaId,
  ) {
    return readMultiple(
      getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
          as DBQuery<CLNote>,
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
              'JOIN Item ON Collection.id = Item.collectionId '
              "WHERE label NOT LIKE '***%' AND "
              'Item.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Item'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.collectionsEmpty => DBQuery<Collection>(
          sql: 'SELECT Collection.* FROM Collection '
              'LEFT JOIN Item ON Collection.id = Item.collectionId '
              'WHERE Item.collectionId IS NULL AND '
              "label NOT LIKE '***%' AND "
              'Item.isDeleted = 0',
          triggerOnTables: const {'Collection', 'Item'},
          fromMap: Collection.fromMap,
        ),
      DBQueries.mediaById => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE id = ?',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaAll => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE isHidden IS 0 AND isDeleted IS 0',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByCollectionId => DBQuery<CLMedia>(
          sql:
              'SELECT * FROM Item WHERE collectionId = ? AND isHidden IS 0 AND isDeleted IS 0',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByMD5 => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE md5String = ?',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaPinned => DBQuery<CLMedia>(
          sql:
              "SELECT * FROM Item WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden IS 0 AND isDeleted IS 0",
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaStaled => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE isHidden IS NOT 0 AND isDeleted IS 0',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaDeleted => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE isDeleted IS NOT 0 ',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByPath => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE path = ?',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByIdList => DBQuery<CLMedia>(
          sql: 'SELECT * FROM Item WHERE id IN (?)',
          triggerOnTables: const {'Item'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.mediaByNoteID => DBQuery<CLMedia>(
          sql:
              'SELECT Item.* FROM Item JOIN ItemNote ON Item.id = ItemNote.itemId WHERE ItemNote.noteId = ?;',
          triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
          fromMap: CLMedia.fromMap,
        ),
      DBQueries.notesAll => DBQuery<CLNote>(
          sql: 'SELECT * FROM Notes',
          triggerOnTables: const {'Notes'},
          fromMap: CLNote.fromMap,
        ),
      DBQueries.noteById => DBQuery<CLNote>(
          sql: 'SELECT * FROM Notes WHERE id = ?;',
          triggerOnTables: const {'Notes'},
          fromMap: CLNote.fromMap,
        ),
      DBQueries.noteByPath => DBQuery<CLNote>(
          sql: 'SELECT * FROM Notes WHERE path = ?;',
          triggerOnTables: const {'Notes'},
          fromMap: CLNote.fromMap,
        ),
      DBQueries.notesByMediaId => DBQuery<CLNote>(
          sql:
              'SELECT Notes.* FROM Notes JOIN ItemNote ON Notes.id = ItemNote.noteId WHERE ItemNote.itemId = ?;',
          triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
          fromMap: CLNote.fromMap,
        ),
      DBQueries.notesOrphan => DBQuery<CLNote>(
          sql:
              'SELECT n.* FROM Notes n LEFT JOIN ItemNote inote ON n.id = inote.noteId WHERE inote.noteId IS NULL',
          triggerOnTables: const {'Notes', 'ItemNote'},
          fromMap: CLNote.fromMap,
        ),
    };
    if (parameters == null) {
      return rawQuery as StoreQuery<T>;
    } else {
      return rawQuery.copyWith(parameters: parameters) as StoreQuery<T>;
    }
  }
}
