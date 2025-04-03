import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';
import 'db_utils/db_command.dart';

import 'm4_db_exec.dart';

@immutable
class DBWriter {
  const DBWriter({
    required this.mediaTable,
  });

  final DBExec<CLEntity> mediaTable;

  Future<CLEntity> upsertMedia(
    SqliteWriteContext tx,
    CLEntity media,
  ) async {
    final CLEntity mediaInDB;
    if (media.isCollection) {
      mediaInDB = (await mediaTable.upsert(
        tx,
        media,
        uniqueColumn: ['id', 'label'],
      ))!;
    } else {
      mediaInDB = (await mediaTable.upsert(
        tx,
        media,
        uniqueColumn: ['id', 'md5'],
      ))!;
    }

    return mediaInDB;
  }

  Future<bool> updateMediaFromMap(
    SqliteWriteContext tx,
    Map<String, dynamic> map,
  ) async {
    return DBCommand.update(map, table: mediaTable.table).execute(tx);
  }

  Future<void> deleteMedia(SqliteWriteContext tx, CLEntity media) async {
    await mediaTable.delete(tx, media);
  }

  Future<CLMedias> upsertMedias(
    SqliteWriteContext tx, {
    required CLMedias medias,
  }) async {
    final cs = medias.entries.where((e) => e.isCollection);
    final ms = medias.entries.where((e) => !e.isCollection);

    final items = <CLEntity>[];

    if (cs.isNotEmpty) {
      items.addAll(
        await mediaTable.upsertAll(
          tx,
          cs.toList(),
          uniqueColumn: ['id', 'label'],
        ),
      );
    }
    if (cs.isNotEmpty) {
      items.addAll(
        await mediaTable.upsertAll(
          tx,
          ms.toList(),
          uniqueColumn: ['id', 'md5String'],
        ),
      );
    }
    return CLMedias(items);
  }
}

/* const _filePrefix = 'DB Write: ';
bool _disableInfoLogger = true;

void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
} */
