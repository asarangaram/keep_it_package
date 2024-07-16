import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqlite_async/sqlite_async.dart';

import '../providers/p2_db_manager.dart';
import 'm2_db_migration.dart';
import 'm3_db_queries.dart';
import 'm3_db_reader.dart';
import 'm4_db_writer.dart';

class DBManager extends Store {
  DBManager({required this.db})
      : dbWriter = DBWriter(),
        dbReader = const DBReader();

  final SqliteDatabase db;
  final DBWriter dbWriter;
  final DBReader dbReader;

  static Future<DBManager> createInstances({
    required String dbpath,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db);
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
  Future<void> togglePin(
    CLMedia media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.togglePin(
        tx,
        media,
        onPin: onPin,
        onRemovePin: onRemovePin,
      );
    });
  }

  @override
  Future<void> pinMediaMultiple(
    List<CLMedia> media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.pinMediaMultiple(
        tx,
        media,
        onPin: onPin,
        onRemovePin: onRemovePin,
      );
    });
  }

  @override
  Future<void> unpinMediaMultiple(
    List<CLMedia> media, {
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.unpinMediaMultiple(
        tx,
        media,
        onRemovePinMultiple: onRemovePinMultiple,
      );
    });
  }

  @override
  Future<List<Object?>?> rawQuery(
    String query,
  ) async {
    final json = (await db.getAll(query, [])).rows.map((e) => e[0]).toList();

    return json;
  }

  @override
  Future<List<Object?>?> getDBRecords() async {
    final dbArchive = await rawQuery(backupQuery);
    return dbArchive;
  }

  @override
  Future<void> reloadStore(WidgetRef ref) async {
    ref.invalidate(storeProvider);
  }
}
