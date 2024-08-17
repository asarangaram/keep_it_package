// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'backup_query.dart';
import 'ext_sqlite_database.dart';
import 'm2_db_migration.dart';
import 'm3_db_query.dart';
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
  }

  final SqliteDatabase db;
  late final DBWriter dbWriter;

  final VoidCallback onReload;

  static Future<DBManager> createInstances({
    required String dbpath,
    required VoidCallback onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db, onReload: onReload);
  }

  @override
  void dispose() {
    db.close();
  }

  @override
  Future<T?> read<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).read(db);
  }

  @override
  Future<List<T>> readMultiple<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).readMultiple(db);
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
  Future<List<CLMedia>> getMediaByCollectionId(
    SqliteWriteContext tx,
    int collectionId,
  ) async {
    return readMultiple<CLMedia>(
      getQuery(DBQueries.mediaByCollectionId, parameters: [collectionId])
          as DBQuery<CLMedia>,
    );
  }

  @override
  Future<void> deleteCollection(Collection collection) async {
    throw Exception('currently not implelemented');
  }

  Future<List<CLNote>?> getNotesByMediaID(
    int mediaId,
  ) {
    return readMultiple(
      getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
          as DBQuery<CLNote>,
    );
  }

  @override
  Future<void> deleteMedia(CLMedia media, {required bool permanent}) async {
    if (permanent) {
      final notes = await getNotesByMediaID(media.id!);
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

  Future<List<CLMedia>?> getMediaByNoteID(
    int noteId,
  ) async {
    return readMultiple(
      getQuery(DBQueries.mediaByNoteID, parameters: [noteId])
          as DBQuery<CLMedia>,
    );
  }

  @override
  Future<void> deleteNote(CLNote note) async {
    final media = await getMediaByNoteID(note.id!);

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

  @override
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
