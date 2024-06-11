import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm2_db_migration.dart';
import 'm3_db_reader.dart';
import 'm4_db_writer.dart';

abstract class Store {
  Future<Collection> upsertCollection({
    required Collection collection,
  });
  Future<CLMedia?> upsertMedia({
    required int collectionId,
    required CLMedia media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });
  Future<void> upsertMediaMultiple({
    required int collectionId,
    required List<CLMedia>? media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });

  Future<void> deleteCollection(
    Collection collection, {
    required Future<void> Function(Directory dir) onDeleteDir,
  });
  Future<void> deleteMedia(
    CLMedia media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> deleteMediaMultiple(
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  });
  Future<void> togglePin(
    CLMedia media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> pinMediaMultiple(
    List<CLMedia> media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> unpinMediaMultiple(
    List<CLMedia> media, {
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  });
  Future<CLNote> upsertNote(
    CLNote note,
    List<CLMedia> mediaList, {
    required Future<CLNote> Function(
      CLNote note, {
      required String targetDir,
    }) onSaveNote,
  });
}

class DBManager extends Store {
  DBManager({required this.db, required AppSettings appSettings})
      : dbWriter = DBWriter(appSettings: appSettings),
        dbReader = DBReader(appSettings: appSettings);

  final SqliteDatabase db;
  final DBWriter dbWriter;
  final DBReader dbReader;

  static Future<DBManager> createInstances({
    required String dbpath,
    required AppSettings appSettings,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db, appSettings: appSettings);
  }

  void dispose() {
    db.close();
  }

  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async {
    return dbReader.getMediaByMD5(db, md5String);
  }

  Future<Collection?> getCollectionByLabel(String label) async {
    return dbReader.getCollectionByLabel(db, label);
  }

  @override
  Future<Collection> upsertCollection({
    required Collection collection,
  }) async {
    return db.writeTransaction<Collection>((tx) async {
      final collectionWithId = await dbWriter.upsertCollection(tx, collection);
      return collectionWithId;
    });
  }

  @override
  Future<void> upsertMediaMultiple({
    required int collectionId,
    required List<CLMedia>? media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  }) async {
    await db.writeTransaction((tx) async {
      if (media?.isEmpty ?? true) return;
      final updatedMedia = <CLMedia>[];
      for (final item in media!) {
        try {
          final updated = await onPrepareMedia(
            item.copyWith(collectionId: collectionId),
            targetDir: dbWriter.appSettings.validPrefix(collectionId),
          );
          updatedMedia.add(updated);
        } catch (e) {/* */}
      }
      await dbWriter.upsertMediaMultiple(tx, updatedMedia);
    });
  }

  @override
  Future<CLMedia?> upsertMedia({
    required int collectionId,
    required CLMedia media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  }) async {
    final dbMedia = await db.writeTransaction<CLMedia?>((tx) async {
      try {
        final updated = await onPrepareMedia(
          media.copyWith(collectionId: collectionId),
          targetDir: dbWriter.appSettings.validPrefix(collectionId),
        );
        return await dbWriter.upsertMedia(tx, updated);
      } catch (e) {
        return null;
      }
    });
    return dbMedia;
  }

  @override
  Future<void> deleteCollection(
    Collection collection, {
    required Future<void> Function(Directory dir) onDeleteDir,
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteCollection(
        tx,
        collection,
        onDeleteDir: onDeleteDir,
      );
    });
  }

  @override
  Future<void> deleteMedia(
    CLMedia media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    await db.writeTransaction((tx) async {
      if (media.id == null) return;
      if (media.pin != null) {
        final res = await dbWriter.togglePin(
          tx,
          media,
          onPin: (media, {required title, desc}) async {
            throw Exception('Unexpected');
          },
          onRemovePin: onRemovePin,
        );
        if (!res) return;
      }
      await dbWriter.deleteMedia(
        tx,
        media,
        onDeleteFile: onDeleteFile,
      );
    });
  }

  @override
  Future<void> deleteMediaMultiple(
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  }) async {
    await db.writeTransaction((tx) async {
      final res = await dbWriter.unpinMediaMultiple(
        tx,
        media,
        onRemovePinMultiple: onRemovePinMultiple,
      );
      if (res) {
        await dbWriter.deleteMediaList(
          tx,
          media,
          onDeleteFile: onDeleteFile,
        );
      }
    });
  }

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
  Future<CLNote> upsertNote(
    CLNote note,
    List<CLMedia> mediaList, {
    required Future<CLNote> Function(
      CLNote note, {
      required String targetDir,
    }) onSaveNote,
  }) async {
    final targetDir = dbWriter.appSettings.notesDir;
    final updated = await onSaveNote(note, targetDir: targetDir);
    return db.writeTransaction((tx) async {
      return dbWriter.upsertNote(tx, updated, mediaList);
    });
  }
}

extension ExtSqliteDatabase on SqliteDatabase {
  Stream<List<Row>> watchRows(
    String sql, {
    Set<String> triggerOnTables = const {},
    List<Object?> parameters = const [],
  }) async* {
    yield await getAll(sql, parameters);
    if (triggerOnTables.isNotEmpty) {}
    {
      final stream = watch(
        sql,
        parameters: parameters,
        triggerOnTables: triggerOnTables.toList(),
      );
      await for (final event in stream) {
        final rows = <Row>[];
        final iterator = event.iterator;
        while (iterator.moveNext()) {
          final row = iterator.current;
          rows.add(row);
        }
        yield rows;
      }
    }
  }
}
