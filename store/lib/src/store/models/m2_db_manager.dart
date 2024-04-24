import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:gal/gal.dart';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

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
  });
  Future<void> deleteMediaMultiple(
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
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
        await Gal.putImage(updated.path);

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
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteMedia(tx, media, onDeleteFile: onDeleteFile);
    });
  }

  @override
  Future<void> deleteMediaMultiple(
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
  }) async {
    await db.writeTransaction((tx) async {
      await dbWriter.deleteMediaList(tx, media, onDeleteFile: onDeleteFile);
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

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        label TEXT NOT NULL UNIQUE,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_collection
        AFTER UPDATE ON Collection
        BEGIN
            UPDATE Collection
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        collectionId INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (collectionId) REFERENCES Collection(id)
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_item
        AFTER UPDATE ON Item
        BEGIN
            UPDATE Item
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
    }),
  );
