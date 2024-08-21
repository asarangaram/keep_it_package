// ignore_for_file: lines_longer_than_80_chars

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'backup_query.dart';
import 'm3_db_queries.dart';
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

  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters}) =>
      Queries.getQuery(query, parameters: parameters);

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
