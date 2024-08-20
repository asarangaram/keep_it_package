import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'ext_sqlite_database.dart';
import 'm2_db_migration.dart';
import 'm3_db_query.dart';
import 'm3_db_reader.dart';
import 'm4_db_exec.dart';
import 'm4_db_writer.dart';

class DBManager extends Store {
  DBManager({required this.db, required this.onReload}) {
    final collectionTable = DBExec<Collection>(
      table: 'Collection',
      toMap: (obj) {
        return obj.toMap();
      },
      readBack: (
        tx,
        collection,
      ) async {
        return (getQuery(
          DBQueries.collectionByLabel,
        ) as DBQuery<Collection>)
            .copyWith(parameters: [collection.label]).read(tx);
      },
    );

    final mediaTable = DBExec<CLMedia>(
      table: 'Item',
      toMap: (CLMedia obj) => obj.toMap(),
      readBack: (tx, item) {
        return (getQuery(DBQueries.mediaByPath) as DBQuery<CLMedia>)
            .copyWith(parameters: [item.label]).read(tx);
      },
    );
    final notesTable = DBExec<CLNote>(
      table: 'Notes',
      toMap: (CLNote obj) => obj.toMap(),
      readBack: (tx, item) async {
        return (getQuery(DBQueries.noteByPath) as DBQuery<CLNote>)
            .copyWith(parameters: [item.path]).read(tx);
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
    dbWriter = DBWriter(
      collectionTable: collectionTable,
      mediaTable: mediaTable,
      notesTable: notesTable,
      notesOnMediaTable: notesOnMediaTable,
    );
    dbReader = DBReader(db);
  }

  final SqliteDatabase db;
  late final DBWriter dbWriter;
  late final DBReader dbReader;

  final void Function() onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required void Function() onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db, onReload: onReload);
  }

  @override
  void dispose() {
    db.close();
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
    throw Exception('currently not implelemented');
  }

  @override
  Future<void> deleteMedia(CLMedia media, {required bool permanent}) async {
    if (permanent) {
      final notes = await dbReader.getNotesByMediaID(media.id!);
      await db.writeTransaction((tx) async {
        if (notes != null && notes.isNotEmpty) {
          for (final n in notes) {
            await dbWriter.disconnectNotes(tx, note: n, media: media);
          }
        }
        await dbWriter.deleteMedia(tx, media);
      });
    } else {
      // Soft Delete
      await db.writeTransaction((tx) async {
        await dbWriter.upsertMedia(
          tx,
          media.removePin().copyWith(isDeleted: true),
        );
      });
    }
  }

  @override
  Future<void> deleteNote(CLNote note) async {
    final media = await dbReader.getMediaByNoteID(note.id!);

    await db.writeTransaction((tx) async {
      if (media != null && media.isNotEmpty) {
        for (final m in media) {
          await dbWriter.disconnectNotes(tx, media: m, note: note);
        }
      }
      await dbWriter.deleteNote(tx, note);
    });
  }
  //////////////////////////////////////////////////////////////////////////////

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
}
