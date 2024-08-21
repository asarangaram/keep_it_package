import 'package:http/http.dart' as http;

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
import 'm4_db_writer_server_extension.dart';

@immutable
class DBManager extends Store {
  factory DBManager({
    required SqliteDatabase db,
    required void Function() onReload,
    required CLServer? server,
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
          DBQueries.mediaByPath,
          parameters: [media.label],
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
    final dbWriter = DBWriter(
      collectionTable: collectionTable,
      mediaTable: mediaTable,
      notesOnMediaTable: notesOnMediaTable,
    );
    final dbReader = DBReader(db);
    return DBManager._(
      db: db,
      onReload: onReload,
      server: server,
      dbReader: dbReader,
      dbWriter: dbWriter,
    );
  }
  DBManager._({
    required this.db,
    required this.onReload,
    required this.server,
    required this.dbWriter,
    required this.dbReader,
  });

  final SqliteDatabase db;
  final DBWriter dbWriter;
  final DBReader dbReader;
  final CLServer? server;

  final void Function() onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required void Function() onReload,
    CLServer? server,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = DBManager(db: db, onReload: onReload, server: server);
    await dbManager.pull();
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
    CLServer? server,
    void Function()? onReload,
  }) {
    return DBManager._(
      db: db ?? this.db,
      dbWriter: dbWriter ?? this.dbWriter,
      dbReader: dbReader ?? this.dbReader,
      server: server ?? this.server,
      onReload: onReload ?? this.onReload,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DBManager(db: $db, dbWriter: $dbWriter, dbReader: $dbReader, server: $server, onReload: $onReload)';
  }

  @override
  bool operator ==(covariant DBManager other) {
    if (identical(this, other)) return true;

    return other.db == db &&
        other.dbWriter == dbWriter &&
        other.dbReader == dbReader &&
        other.server == server &&
        other.onReload == onReload;
  }

  @override
  int get hashCode {
    return db.hashCode ^
        dbWriter.hashCode ^
        dbReader.hashCode ^
        server.hashCode ^
        onReload.hashCode;
  }

  @override
  Future<DBManager> attachServer(CLServer? value) async {
    final dbManager = DBManager._(
      db: db,
      onReload: onReload,
      dbWriter: dbWriter,
      dbReader: dbReader,
      server: value,
    );
    await dbManager.pull();
    return dbManager;
  }

  Future<SyncStatus> push() async {
    /* final updatedCollections =  */ await dbReader
        .locallyModifiedCollections();
    if ((await server?.hasConnection()) ?? false) {
    } else {
      throw Exception('Server not found');
    }
    throw UnimplementedError();
  }

  Future<SyncStatus> pull({
    http.Client? client,
  }) async {
    if (server == null) return SyncStatus.serverNotConfigured;
    await db.writeTransaction((tx) async {
      final res =
          await dbWriter.pullCollection(tx, server: server!, client: client);
      if (res != SyncStatus.success) {
        return res;
      }
    });
    return SyncStatus.success;
  }
}
