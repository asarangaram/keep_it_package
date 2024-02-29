import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm1_app_settings.dart';

extension SQLEXTDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}

extension CLMediaDB on CLMedia {
  static String relativePath(String path, String pathPrefix) {
    if (path.startsWith(pathPrefix)) {
      return path.replaceFirst(pathPrefix, '');
    }
    // Paths outside the storage, lets keep the absoulte path
    return path;
  }

  Future<void> upsert(SqliteWriteContext tx) async {
    if (id != null) {
      await tx.execute(
        'UPDATE  Item SET path = ?, '
        'ref = ?, collection_id = ?, type=?, originalDate=?, md5String=? '
        'WHERE id = ?',
        [
          path,
          ref,
          collectionId,
          type.name,
          originalDate.toSQL(),
          md5String,
          id,
        ],
      );
    } else {
      await tx.execute(
        'INSERT  INTO Item (path, '
        'ref, collection_id, type, originalDate, md5String) '
        'VALUES (?, ?, ?, ?, ?, ?) ',
        [
          path,
          ref,
          collectionId,
          type.name,
          originalDate.toSQL(),
          md5String,
        ],
      );
    }
  }

  Future<void> delete(SqliteWriteContext tx) async {
    if (id == null) return;
    await tx.execute('DELETE FROM Item WHERE id = ?', [id]);
  }

  static Map<String, dynamic> preprocessMediaMap(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
    bool validate = true,
  }) {
    return map.map((key, value) {
      final String v;
      if (key == 'path' &&
          CLMediaType.values
              .where((e) => e.isFile)
              .map((e) => e.name)
              .contains(map['type'])) {
        final path = value as String;
        final collectionID = map['collection_id'] as int;

        if (validate && !File(path).existsSync()) {
          throw Exception('file not found');
        }
        final prefix = appSettings.validPrefix(collectionID);
        if (validate && path.startsWith(prefix)) {
          throw Exception('Media is not placed in appropriate folder');
        }
        return MapEntry(key, path.replaceFirst(prefix, ''));
      } else {
        v = value as String;
        return MapEntry(key, v);
      }
    });
  }

  static Map<String, dynamic> postprocess(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
    bool validate = true,
  }) {
    return map.map((key, value) {
      if (key == 'path' &&
          CLMediaType.values
              .where((e) => e.isFile)
              .map((e) => e.name)
              .contains(map['type'])) {
        final collectionID = map['collection_id'] as int;
        final path = value as String;

        return MapEntry(
          key,
          '${appSettings.validPrefix(collectionID)}/$path',
        );
      } else {
        return MapEntry(key, value);
      }
    });
  }
}
