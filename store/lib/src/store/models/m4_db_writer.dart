import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store/models/m3_db_query.dart';

import 'm3_db_queries.dart';
import 'm4_db_exec.dart';

@immutable
class DBWriter {
  DBWriter({required this.appSettings});
  final DBExec<Collection> collectionTable = DBExec<Collection>(
    table: 'Collection',
    toMap: (obj, {required appSettings, required validate}) {
      return obj.toMap();
    },
    readBack: (
      tx,
      collection, {
      required appSettings,
      required validate,
    }) async {
      return (DBQueries.collectionByLabel.sql as DBQuery<Collection>)
          .copyWith(parameters: [collection.label]).read(
        tx,
        appSettings: appSettings,
        validate: validate,
      );
    },
  );

  final DBExec<CLMedia> mediaTable = DBExec<CLMedia>(
    table: 'Item',
    toMap: (CLMedia obj, {required appSettings, required validate}) {
      final map = obj.toMap(
        pathPrefix: appSettings.directories.docDir.path,
        validate: true,
      );
      if (validate) {
        final collectionId = map['collectionId'] as int?;
        if (collectionId == null) {
          exceptionLogger(
            'Invalid Media',
            "Media can't be saved without collectionID",
          );
        }

        final prefix = appSettings.validRelativePrefix(collectionId!);
        if (obj.type.isFile && !(map['path'] as String).startsWith(prefix)) {
          exceptionLogger(
            'Invalid Media',
            'Media is not in the expected to be in the '
                'folder: $prefix. \nCurrent file: ${map['path']}',
          );
        }
      }
      return map;
    },
    readBack: (tx, item, {required appSettings, required validate}) {
      final pathExpected = CLMedia.relativePath(
        item.path,
        pathPrefix: appSettings.directories.docDir.path,
        validate: true,
      );

      return (DBQueries.mediaByPath.sql as DBQuery<CLMedia>)
          .copyWith(parameters: [pathExpected]).read(
        tx,
        appSettings: appSettings,
        validate: validate,
      );
    },
  );

  final AppSettings appSettings;

  Future<Collection> upsertCollection(
    SqliteWriteContext tx,
    Collection collection,
  ) async {
    _infoLogger('upsertCollection: $collection');
    final updated = await collectionTable.upsert(
      tx,
      collection,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertCollection: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Collection',
      );
    }
    return updated!;
  }

  Future<List<CLMedia?>> upsertMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media,
  ) async {
    _infoLogger('upsertMediaMultiple: $media');
    final updated = await mediaTable.upsertAll(
      tx,
      media,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertMediaMultiple: Done :  $updated');
    if (updated.any((e) => e == null)) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Collection',
      );
    }
    return updated;
  }

  Future<CLMedia> upsertMedia(SqliteWriteContext tx, CLMedia media) async {
    _infoLogger('upsertMedia: $media');
    final updated = await mediaTable.upsert(
      tx,
      media,
      appSettings: appSettings,
      validate: true,
    );
    _infoLogger('upsertMedia: Done :  $updated');
    if (updated == null) {
      exceptionLogger(
        '$_filePrefix: DB Failure',
        '$_filePrefix: Failed to write / retrive Media',
      );
    }
    return updated!;
  }

  Future<void> deleteCollection(
    SqliteWriteContext tx,
    Collection collection, {
    required Future<void> Function(Directory dir) onDeleteDir,
  }) async {
    if (collection.id == null) return;
    await onDeleteDir(Directory(appSettings.validPrefix(collection.id!)));

    await mediaTable.delete(tx, {'collectionId': collection.id.toString()});
    await collectionTable.delete(tx, {'id': collection.id.toString()});
  }

  Future<void> deleteMedia(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<void> Function(File file) onDeleteFile,
  }) async {
    if (media.id == null) return;
    await onDeleteFile(File(media.path));
    await mediaTable.delete(tx, {'id': media.id.toString()});
  }

  Future<void> deleteMediaList(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
  }) async {
    for (final m in media) {
      if (m.id != null) {
        await deleteMedia(tx, m, onDeleteFile: onDeleteFile);
      }
    }
  }

  Future<void> togglePin(
    SqliteWriteContext tx,
    CLMedia media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    if (media.id == null) return;

    if (media.pin == null || media.pin!.isEmpty) {
      final pin = await onPin(media, title: basename(media.path));
      if (pin == null) return;
      final pinnedMedia = media.copyWith(pin: pin);
      await upsertMedia(tx, pinnedMedia);
    } else {
      final id = media.pin!;
      if (await onRemovePin(id)) {
        final pinnedMedia = media.removePin();
        await upsertMedia(tx, pinnedMedia);
      }
    }
  }

  Future<void> pinMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  }) async {
    final unpinned = media.where((e) => e.pin == null).toList();
    for (final item in unpinned) {
      await togglePin(tx, item, onPin: onPin, onRemovePin: onRemovePin);
    }
  }

  Future<void> unpinMediaMultiple(
    SqliteWriteContext tx,
    List<CLMedia> media, {
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  }) async {
    final pinned = media.where((e) => e.pin != null).toList();
    final res = await onRemovePinMultiple(pinned.map((e) => e.pin!).toList());
    if (res) {
      for (final item in pinned) {
        final pinnedMedia = item.removePin();
        await upsertMedia(tx, pinnedMedia);
      }
    }
  }
}

const _filePrefix = 'DB Write: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
