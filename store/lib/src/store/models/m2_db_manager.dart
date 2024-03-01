import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';

import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/collection.dart';
import 'package:store/src/store/models/m1_app_settings.dart';

import 'm4_db_exec.dart';
import 'tags_in_collection.dart';

@immutable
class DBWriter {
  DBWriter({required this.appSettings});
  final DBTable<Collection> collectionTable = DBTable<Collection>(
    table: 'Collection',
    toMap: (Collection c) => c.toMap(),
  );
  final DBTable<Tag> tagTable = DBTable<Tag>(
    table: 'Collection',
    toMap: (Tag c) => c.toMap(),
  );
  final DBTable<CLMedia> mediaTable = DBTable<CLMedia>(
    table: 'Collection',
    toMap: (CLMedia c) => c.toMap(),
  );
  final DBTable<TagCollection> tagCollectionTable = DBTable<TagCollection>(
    table: 'TagCollection',
    toMap: (TagCollection c) => c.toMap(),
  );
  final AppSettings appSettings;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    return (await collectionTable.upsert(tx, collection, appSettings))!;
  }

  Future<void> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media,
  ) async {
    await mediaTable.upsertAll(tx, media, appSettings);
  }

  Future<void> replaceTags(
    SqliteWriteContext tx,
    Collection collection,
    List<Tag>? newTagsListToReplace,
  ) async {
    if (newTagsListToReplace?.isNotEmpty ?? false) {
      final newTags = newTagsListToReplace!.where((e) => e.id == null).toList();
      final tags = newTagsListToReplace.where((e) => e.id != null).toList();

      for (final tag in newTags) {
        tags.add((await tagTable.upsert(tx, tag, appSettings))!);
      }
      await collection.removeAllTags(tx);
      await tagCollectionTable.upsertAll(
        tx,
        tags
            .map(
              (e) => TagCollection(tagID: e.id!, collectionId: collection.id!),
            )
            .toList(),
        appSettings,
      );
    }
  }
}

class DBManager {
  DBManager({required this.db, required AppSettings appSettings})
      : dbWriter = DBWriter(appSettings: appSettings);

  final SqliteDatabase db;
  final DBWriter dbWriter;

  static Future<DBManager> createInstances({
    required String dbpath,
    required AppSettings appSettings,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    return DBManager(db: db, appSettings: appSettings);
  }

  Stream<Progress> upsertCollectionWithMedia({
    required Collection collection,
    required List<Tag>? newTagsListToReplace,
    required List<CLMedia>? media,
    required void Function() onDone,
  }) async* {
    {
      await db.writeTransaction((tx) async {
        final collectionWithId =
            await dbWriter.upsertCollection(tx, collection);
        await dbWriter.replaceTags(tx, collectionWithId, newTagsListToReplace);
        if (media?.isNotEmpty ?? false) {
          final updatedMedia = <CLMedia>[];
          for (final item in media!) {
            var updated = item.copyWith(collectionId: collectionWithId.id);
            updated = await updated.moveFile(
              targetDir: dbWriter.appSettings.validPrefix(collectionWithId.id!),
            );
            updatedMedia.add(updated);
          }
          await dbWriter.upsertMediaMultiple(tx, updatedMedia);
        }
      });
      onDone();
    }
  }

  Stream<Progress> upsertMedia({
    required Collection collection,
    required List<CLMedia>? media,
    required void Function() onDone,
  }) async* {
    {
      await db.writeTransaction((tx) async {
        if (media?.isNotEmpty ?? false) {
          final updatedMedia = <CLMedia>[];
          for (final item in media!) {
            var updated = item.copyWith(collectionId: collection.id);
            updated = await updated.moveFile(
              targetDir: dbWriter.appSettings.validPrefix(collection.id!),
            );
            updatedMedia.add(updated);
          }
          await dbWriter.upsertMediaMultiple(tx, updatedMedia);
        }
      });
      onDone();
    }
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
        collection_id INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (collection_id) REFERENCES Collection(id)
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
        tag_id INTEGER,
        collection_id INTEGER,
        FOREIGN KEY (tag_id) REFERENCES Tag(id),
        FOREIGN KEY (collection_id) REFERENCES Collection(id),
        PRIMARY KEY (tag_id, collection_id)
      )
    ''');
    }),
  );
