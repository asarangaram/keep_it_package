import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm2_db_migration.dart';

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
    final mediaTable = DBExec<CLEntity>(
      table: 'Media',
      toMap: (CLEntity obj) => obj.toMap(),
      readBack: readBack,
    );

    final dbWriter = DBWriter(
      mediaTable: mediaTable,
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

  static Future<CLEntity?> readBack(
    SqliteWriteContext tx,
    CLEntity media,
  ) async {
    final dbReader = DBReader(tx);
    final q = await dbReader.formQuery<CLEntity>(
      {
        if (media.isCollection) 'label': media.label else 'md5': media.md5,
      },
    );
    return (q as DBQuery<CLEntity>).get(tx);
  }

  static Future<CLEntity?> readBackById(
    SqliteWriteContext tx,
    int id,
  ) async {
    final dbReader = DBReader(tx);
    final q = await dbReader.formQuery<CLEntity>(
      {
        'id': id,
      },
    );
    return (q as DBQuery<CLEntity>).get(tx);
  }

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
  Future<CLEntity> upsertMedia(CLEntity media) async =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertMedia(tx, media);
      });

  @override
  Future<CLEntity?> updateMediaFromMap(Map<String, dynamic> map) async =>
      db.writeTransaction((tx) async {
        if (await dbWriter.updateMediaFromMap(tx, map)) {
          return readBackById(tx, map['id'] as int);
        }
        return null;
      });

  @override
  Future<void> deleteMedia(CLEntity media) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteMedia(tx, media);
      });

  @override
  Future<void> reloadStore() async => onReload();

  /* 
  Unused, but preserved for logic.
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
        if (dbQuery.getFromMap() != null) {
          return rows
              .map((e) => dbQuery.getFromMap()!(DBQuery.fixedMap(e)))
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
  } */

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
