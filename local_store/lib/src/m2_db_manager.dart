import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'ext_sqlite_database.dart';
import 'm2_db_migration.dart';
import 'm3_db_queries.dart';
import 'm3_db_query.dart';
import 'm3_db_reader.dart';
import 'm4_db_exec.dart';
import 'm4_db_writer.dart';

@immutable
class DBManager extends Store {
  factory DBManager({
    required SqliteDatabase db,
    required void Function() onReload,
  }) {
    final collectionTable = DBExec<Collection>(
      table: 'Collection',
      toMap: (obj) => obj.toMap(),
      readBack: (tx, collection) async {
        return (Queries.getQuery(
          DBQueries.collectionByLabel,
          parameters: [collection.label],
        ) as DBQuery<Collection>)
            .read(tx);
      },
    );

    final mediaTable = DBExec<CLMedia>(
      table: 'Media',
      toMap: (CLMedia obj) => obj.toMap(),
      readBack: (tx, media) {
        return (Queries.getQuery(
          DBQueries.mediaByMD5,
          parameters: [media.md5String],
        ) as DBQuery<CLMedia>)
            .read(tx);
      },
    );

    final notesOnMediaTable = DBExec<NotesOnMedia>(
      table: 'MediaNote',
      toMap: (NotesOnMedia obj) => obj.toMap(),
      readBack: (tx, item) async {
        return item;
      },
    );

    final dbWriter = DBWriter(
      collectionTable: collectionTable,
      mediaTable: mediaTable,
      notesOnMediaTable: notesOnMediaTable,
    );
    final dbReader = DBReader(db);
    return DBManager._(
      dbReader,
      db: db,
      onReload: onReload,
      dbWriter: dbWriter,
    );
  }
  const DBManager._(
    super.reader, {
    required this.db,
    required this.onReload,
    required this.dbWriter,
  });

  final SqliteDatabase db;
  final DBWriter dbWriter;

  final void Function() onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required void Function() onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = DBManager(
      db: db,
      onReload: onReload,
    );

    return dbManager;
  }

  @override
  void dispose() {
    db.close();
  }

  @override
  Future<Collection> upsertCollection(Collection collection) async =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertCollection(tx, collection);
      });

  @override
  Future<CLMedia> upsertMedia(
    CLMedia media, {
    List<CLMedia>? parents,
  }) async =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertMedia(tx, media, parents: parents);
      });

  @override
  Future<CLMedia?> updateMediaFromMap(Map<String, dynamic> map) async =>
      db.writeTransaction((tx) async {
        if (await dbWriter.updateMediaFromMap(tx, map)) {
          final q = reader.getQuery(
            DBQueries.mediaById,
            parameters: [map['id'] as int],
          ) as StoreQuery<CLMedia>;

          return DBReader(tx).read(q);
        }
        return null;
      });

  @override
  Future<void> deleteCollection(Collection collection) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteCollection(tx, collection);
      });

  @override
  Future<void> deleteMedia(CLMedia media) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteMedia(tx, media);
      });

  @override
  Future<void> reloadStore() async => onReload();

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
      (rows) {
        if (dbQuery.fromMap != null) {
          return rows
              .map((e) => dbQuery.fromMap!.call(DBQuery.fixedMap(e)))
              .where((e) => e != null)
              .toList();
        } else {
          return rows.map((e) => e as T).toList();
        }
      },
    );
    await for (final res in sub) {
      yield res;
    }
  }

  DBManager copyWith({
    SqliteDatabase? db,
    DBWriter? dbWriter,
    DBReader? reader,
    void Function()? onReload,
  }) {
    return DBManager._(
      reader ?? this.reader,
      db: db ?? this.db,
      dbWriter: dbWriter ?? this.dbWriter,
      onReload: onReload ?? this.onReload,
    );
  }

  @override
  String toString() {
    return 'DBManager(db: $db, dbWriter: $dbWriter, onReload: $onReload)';
  }

  @override
  bool operator ==(covariant DBManager other) {
    if (identical(this, other)) return true;

    return other.db == db &&
        other.dbWriter == dbWriter &&
        other.onReload == onReload;
  }

  @override
  int get hashCode {
    return db.hashCode ^ dbWriter.hashCode ^ onReload.hashCode;
  }
}
