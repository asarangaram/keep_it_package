import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/extensions/ext_sqlite_database.dart';

import 'm2_db_migration.dart';
import 'm3_db_queries.dart';
import 'm3_db_query.dart';
import 'm3_db_reader.dart';
import 'm4_db_writer.dart';

class DBManager extends Store {
  DBManager({required this.db, required this.onReload})
      : dbWriter = DBWriter(),
        dbReader = const DBReader();

  final SqliteDatabase db;
  final DBWriter dbWriter;
  final DBReader dbReader;
  final VoidCallback onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required VoidCallback onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db, onReload: onReload);
  }

  void dispose() {
    db.close();
  }

  @override
  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async {
    return dbReader.getMediaByMD5(db, md5String);
  }

  @override
  Future<Collection?> getCollectionByLabel(String label) async {
    return dbReader.getCollectionByLabel(db, label);
  }

  @override
  Future<List<CLNote>?> getNotesByMediaID(
    int noteId,
  ) {
    return dbReader.getNotesByMediaID(db, noteId);
  }

  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<Collection> upsertCollection(Collection collection) async {
    return db.writeTransaction<Collection>((tx) async {
      return dbWriter.upsertCollection(tx, collection);
    });
  }

  @override
  Future<CLMedia?> upsertMedia(CLMedia media) async {
    return db.writeTransaction<CLMedia?>((tx) async {
      return dbWriter.upsertMedia(tx, media);
    });
  }

  @override
  Future<CLNote?> upsertNote(CLNote note, List<CLMedia> mediaList) async {
    return db.writeTransaction((tx) async {
      return dbWriter.upsertNote(tx, note, mediaList);
    });
  }

  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<void> deleteCollection(Collection collection) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteCollection(tx, collection);
    });
  }

  @override
  Future<void> deleteMedia(CLMedia media, {required bool permanent}) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteMedia(tx, media, deletePermanently: permanent);
    });
  }

  @override
  Future<void> deleteNote(CLNote note) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteNote(tx, note);
    });
  }
  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<List<Object?>?> getDBRecords() async {
    final dbArchive =
        (await db.getAll(backupQuery, [])).rows.map((e) => e[0]).toList();

    return dbArchive;
  }

  @override
  Future<void> reloadStore() async {
    onReload();
  }

  @override
  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery) async* {
    final dbQuery = storeQuery as DBQuery<T>;
    final sub = db
        .watchRows(
          dbQuery.sql,
          triggerOnTables: dbQuery.triggerOnTables,
          parameters: dbQuery.parameters ?? [],
        )
        .map(
          (rows) => rows
              .map((e) => dbQuery.fromMap(DBQuery.fixedMap(e)))
              .where((e) => e != null)
              .toList(),
        );
    await for (final res in sub) {
      yield res;
    }
  }
}
