import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/cl_media.dart';
import 'package:store/src/store/models/collection.dart';
import 'package:store/src/store/models/m1_app_settings.dart';
import 'package:store/src/store/models/tag.dart';

import 'm3_db_queries.dart';
import 'm3_db_query.dart';

class DBUpdater {
  static Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    await collection.upsertCollection(tx);
    return (await (DBQueries.collectionByLabel.sql as DBQuery<Collection>)
        .copyWith(parameters: [collection.label]).read(tx))!;
  }

  static Future<void> replaceTags(
    SqliteWriteContext tx,
    Collection collection,
    List<Tag>? newTagsListToReplace,
  ) async {
    if (newTagsListToReplace?.isNotEmpty ?? false) {
      final newTags = newTagsListToReplace!.where((e) => e.id == null).toList();
      final tags = newTagsListToReplace.where((e) => e.id != null).toList();

      for (final tag in newTags) {
        await tag.upsertTag(tx);
        final tagWithId = await (DBQueries.tagByLabel.sql as DBQuery<Tag>)
            .copyWith(parameters: [tag.label]).read(tx);
        tags.add(tagWithId!);
      }
      await collection.replaceTags(tx, tags.map((e) => e.id!).toList());
    }
  }
}

class DBManager {
  DBManager({required this.db, required this.appSettings});

  final SqliteDatabase db;
  final AppSettings appSettings;

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
            await DBUpdater.upsertCollection(tx, collection);
        await DBUpdater.replaceTags(tx, collectionWithId, newTagsListToReplace);
        if (media?.isNotEmpty ?? false) {
          for (final item in media!) {
            var updated = item.copyWith(collectionId: collectionWithId.id);
            updated = await updated.moveFile(
              targetDir: appSettings.validPrefix(collectionWithId.id!),
            );
            await updated.upsertMedia(tx);
          }
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
          final mediaUpdated = <CLMedia>[];
          for (final item in media!) {
            var updated = item.copyWith(collectionId: collection.id);
            updated = await updated.moveFile(
              targetDir: appSettings.validPrefix(collection.id!),
            );
            mediaUpdated.add(updated);
          }
          await collection.upsertMedia(tx, media);
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

extension SQLEXTDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}
