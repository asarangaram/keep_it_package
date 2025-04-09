import 'dart:io';

import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import '../implementations/sqlite_db/db_store.dart';
import '../implementations/sqlite_db/db_table_mixin.dart';
import '../implementations/sqlite_db/table_agent.dart';
import 'db_query.dart';

@immutable
class LocalSQLiteEntityStore extends EntityStore
    with SQLiteDBTableMixin<CLEntity> {
  LocalSQLiteEntityStore(
    super.identity,
    this.agent, {
    required this.mediaPath,
    required this.previewPath,
  });
  final SQLiteTableAgent<CLEntity> agent;
  final String mediaPath;
  final String previewPath;

  @override
  Future<bool> delete(CLEntity item) async {
    Future<void> cb(SqliteWriteContext tx) async {
      await dbDelete(tx, agent, item);
    }

    try {
      await agent.db.writeTransaction(cb);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]) async {
    Future<CLEntity?> cb(SqliteWriteContext tx) async {
      return dbGet(tx, agent, query);
    }

    return agent.db.writeTransaction(cb);
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    Future<List<CLEntity>> cb(SqliteWriteContext tx) async {
      return dbGetAll(tx, agent, query);
    }

    return agent.db.writeTransaction(cb);
  }

  String? absoluteMediaPath(CLEntity media) =>
      media.path == null ? null : '$mediaPath/${media.path}';
  String? absolutePreviewPath(CLEntity media) =>
      media.previewPath == null ? null : '$previewPath/${media.previewPath}';

  Future<bool> createMediaFiles(CLEntity media, String path) async {
    final mediaPath = absoluteMediaPath(media);
    final previewPath = absolutePreviewPath(media);

    if (mediaPath != null) {
      final f = File(mediaPath);
      final dirPath = p.dirname(f.path);
      Directory(dirPath).createSync(recursive: true);
      f.copySync(mediaPath);

      await FfmpegUtils.generatePreview(
        mediaPath,
        previewPath: previewPath!,
        dimension: 640,
      );
      return File(mediaPath).existsSync() && File(previewPath).existsSync();
    }
    return false;
  }

  Future<bool> deleteMediaFiles(CLEntity media) async {
    final mediaPath = absoluteMediaPath(media);
    final previewPath = absolutePreviewPath(media);
    for (final path in [mediaPath, previewPath]) {
      if (path != null) {
        final f = File(path);
        if (f.existsSync()) {
          f.deleteSync();
        }
      }
    }
    return mediaPath != null && previewPath != null;
  }

  @override
  Future<CLEntity?> upsert(
    CLEntity curr, {
    String? path,
  }) async {
    CLEntity? prev;
    CLEntity? updated;

    final String? currentMediaPath;
    final String? prevMediaPath;

    try {
      prev = null;
      if (curr.id == null) {
        final timeNow = DateTime.now();
        updated = curr.copyWith(addedDate: timeNow, updatedDate: timeNow);
      } else {
        prev = await get(EntityQuery(null, {'id': curr.id}));
        if (prev == null) {
          throw Exception('media with id ${curr.id} not found');
        }
        if ((prev.md5 == curr.md5) && path != null) {
          throw Exception('path is not expected');
        } else if ((prev.md5 != curr.md5) && path == null) {
          throw Exception('path expected as media changed');
        }
        if (curr.isSame(prev)) {
          // nothing to update!, avoid date change and send prevous
          return prev;
        } else if (curr.isContentSame(prev)) {
          updated = curr.copyWith(
            updatedDate: DateTime.now(),
          );
        } else {
          // few items like, pin and hidden don't change the update date
          // they are just state
          updated = curr;
        }
      }
      currentMediaPath = absoluteMediaPath(curr);
      prevMediaPath = prev == null ? null : absoluteMediaPath(prev);
    } catch (e) {
      return prev;
    }

    Future<CLEntity?> cb(SqliteWriteContext tx) async {
      final entityFromDB = await dbUpsert(tx, agent, curr);
      if (entityFromDB == null) throw Exception('failed to update DB');
      if (currentMediaPath != null &&
          prevMediaPath != currentMediaPath &&
          path != null) {
        await createMediaFiles(curr, path);
      }
      // generate preview here

      return updated;
    }

    try {
      final saved = await agent.db.writeTransaction(cb);
      if (saved != null) {
        if (prev != null && !saved.isContentSame(prev)) {
          if (prevMediaPath != null && prevMediaPath != currentMediaPath) {
            await deleteMediaFiles(prev);
          }
        }
        return saved;
      }
    } catch (e) {
      if (currentMediaPath != null && prevMediaPath != currentMediaPath) {
        await deleteMediaFiles(curr);
      }
    }
    return prev;
  }

  static Future<EntityStore> createStore(
    DBModel db,
    String name, {
    required String mediaPath,
    required String previewPath,
  }) async {
    const tableName = 'entity';
    final sqliteDB = db as SQLiteDB;
    final columnInfo = await db.db.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    final agent = SQLiteTableAgent<CLEntity>(
      db: sqliteDB.db,
      table: 'Entity',
      fromMap: CLEntity.fromMap,
      toMap: (CLEntity obj) => obj.toMap(),
      dbQueryForItem: (CLEntity obj) async => DBQuery.fromStoreQuery(
        tableName,
        validColumns,
        Shortcuts.mediaQuery('ignore', obj), // We use this inside the server.
      ),
      getUniqueColumns: (CLEntity obj) {
        return ['id', if (obj.isCollection) 'label' else 'md5'];
      },
      validColumns: validColumns,
    );

    return LocalSQLiteEntityStore(
      name,
      agent,
      mediaPath: mediaPath,
      previewPath: previewPath,
    );
  }
}

Future<EntityStore> createEntityStore(
  DBModel db,
  String name, {
  required String mediaPath,
  required String previewPath,
}) {
  return switch (db) {
    (final SQLiteDB db) => LocalSQLiteEntityStore.createStore(
        db,
        name,
        mediaPath: mediaPath,
        previewPath: previewPath,
      ),
    _ => throw Exception('Unsupported DB')
  };
}
