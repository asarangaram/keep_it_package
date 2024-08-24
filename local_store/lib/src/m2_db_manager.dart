// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:device_resources/device_resources.dart';
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
    required AppSettings appSettings,
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
      table: 'ItemNote',
      toMap: (NotesOnMedia obj) => obj.toMap(),
      readBack: (tx, item) async {
        // TODO(anandas): :readBack for ItemNote Can this be done?
        return item;
      },
    );

    final mediaServerInfoTable = DBExec<MediaServerInfo>(
      table: 'MediaServerInfo',
      toMap: (MediaServerInfo obj) => obj.toMap(),
      readBack: (tx, mediaServerInfo) async {
        return (Queries.getQuery(
          DBQueries.mediaServerInfoByServerUID,
          parameters: [mediaServerInfo.serverUID],
        ) as DBQuery<MediaServerInfo>)
            .read(tx);
      },
    );

    final dbWriter = DBWriter(
      collectionTable: collectionTable,
      mediaTable: mediaTable,
      notesOnMediaTable: notesOnMediaTable,
      mediaServerInfoTable: mediaServerInfoTable,
    );
    final dbReader = DBReader(db);
    return DBManager._(
      db: db,
      onReload: onReload,
      dbReader: dbReader,
      dbWriter: dbWriter,
      appSettings: appSettings,
    );
  }
  DBManager._({
    required this.db,
    required this.onReload,
    required this.dbWriter,
    required this.dbReader,
    required this.appSettings,
  });

  final SqliteDatabase db;
  final DBWriter dbWriter;
  final DBReader dbReader;

  final AppSettings appSettings;

  final void Function() onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required void Function() onReload,
    required AppSettings appSettings,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = DBManager(
      db: db,
      onReload: onReload,
      appSettings: appSettings,
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
  Future<CLMedia> upsertMedia(CLMedia media) async =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertMedia(tx, media);
      });

  @override
  Future<CLMedia> upsertNote(CLMedia note, List<CLMedia> mediaList) async =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertNote(tx, note, mediaList);
      });

  @override
  Future<MediaServerInfo> upsertServerInfo(MediaServerInfo mediaServerInfo) =>
      db.writeTransaction((tx) async {
        return dbWriter.upsertServerInfo(tx, mediaServerInfo);
      });

  @override
  Future<void> deleteCollection(Collection collection) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteCollection(tx, collection);
      });

  @override
  Future<void> deleteMedia(CLMedia media, {required bool permanent}) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteMedia(tx, media, permanent: permanent);
      });

  @override
  Future<void> deleteNote(CLMedia note) async =>
      db.writeTransaction((tx) async {
        await dbWriter.deleteNote(tx, note);
      });
  @override
  Future<void> deleteServerInfo(MediaServerInfo mediaServerInfo) {
    return db.writeTransaction((tx) async {
      await dbWriter.deleteServerInfo(tx, mediaServerInfo);
    });
  }

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
          (rows) => rows
              .map((e) => dbQuery.fromMap(DBQuery.fixedMap(e)))
              .where((e) => e != null)
              .toList(),
        );
    await for (final res in sub) {
      yield res;
    }
  }

  @override
  Future<List<Object?>?> getDBRecords() => dbReader.getDBRecords();

  @override
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters}) =>
      dbReader.getQuery(query, parameters: parameters);

  @override
  Future<T?> read<T>(StoreQuery<T> query) => dbReader.read(query);

  @override
  Future<List<T?>> readMultiple<T>(StoreQuery<T> query) =>
      dbReader.readMultiple(query);

  DBManager copyWith({
    SqliteDatabase? db,
    DBWriter? dbWriter,
    DBReader? dbReader,
    AppSettings? appSettings,
    void Function()? onReload,
  }) {
    return DBManager._(
      db: db ?? this.db,
      dbWriter: dbWriter ?? this.dbWriter,
      dbReader: dbReader ?? this.dbReader,
      appSettings: appSettings ?? this.appSettings,
      onReload: onReload ?? this.onReload,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DBManager(db: $db, dbWriter: $dbWriter, dbReader: $dbReader, appSettings: $appSettings, onReload: $onReload)';
  }

  @override
  bool operator ==(covariant DBManager other) {
    if (identical(this, other)) return true;

    return other.db == db &&
        other.dbWriter == dbWriter &&
        other.dbReader == dbReader &&
        other.appSettings == appSettings &&
        other.onReload == onReload;
  }

  @override
  int get hashCode {
    return db.hashCode ^
        dbWriter.hashCode ^
        dbReader.hashCode ^
        appSettings.hashCode ^
        onReload.hashCode;
  }
}
