import 'package:colan_widgets/colan_widgets.dart';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/m1_app_settings.dart';
import 'm3_db_reader.dart';
import 'm4_db_writer.dart';

abstract class Store {
  Future<Collection> upsertCollection({
    required Collection collection,
    required List<Tag>? newTagsListToReplace,
  });
  Future<void> upsertMediaMultiple(List<CLMedia> media);
  Future<void> deleteCollection(
    Collection collection, {
    required Future<void> Function(List<CLMedia> media) onDeleteMediaFiles,
  });
  Future<void> deleteMedia(CLMedia media);
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

  @override
  Future<Collection> upsertCollection({
    required Collection collection,
    required List<Tag>? newTagsListToReplace,
  }) async {
    return db.writeTransaction<Collection>((tx) async {
      final collectionWithId = await dbWriter.upsertCollection(tx, collection);
      await dbWriter.replaceTags(tx, collectionWithId, newTagsListToReplace);
      return collectionWithId;
    });
  }

  @override
  Future<void> upsertMediaMultiple(List<CLMedia> media) async {
    await db.writeTransaction((tx) async {
      await dbWriter.upsertMediaMultiple(tx, media);
    });
  }

  @override
  Future<void> deleteCollection(
    Collection collection, {
    required Future<void> Function(List<CLMedia> media) onDeleteMediaFiles,
  }) async {
    if (collection.id == null) return;
    final media = await dbReader.getMediaByCollectionId(db, collection.id!);
    if (media.isNotEmpty) {
      await onDeleteMediaFiles(media);
    }
    await db.writeTransaction((tx) async {
      await dbWriter.deleteCollection(tx, collection);
    });
  }

  @override
  Future<void> deleteMedia(CLMedia media) async {
    if (media.id == null) return;
    await db.writeTransaction((tx) async {
      await dbWriter.deleteMedia(tx, media);
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
      CREATE TABLE IF NOT EXISTS Tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_tag
        AFTER UPDATE ON Tag
        BEGIN
            UPDATE Tag
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
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
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS TagCollection (
        tagId INTEGER,
        collectionId INTEGER,
        FOREIGN KEY (tagId) REFERENCES Tag(id),
        FOREIGN KEY (collectionId) REFERENCES Collection(id),
        PRIMARY KEY (tagId, collectionId)
      )
    ''');
    }),
  );
