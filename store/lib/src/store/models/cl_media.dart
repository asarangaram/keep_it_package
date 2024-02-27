import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart';

import 'device_directories.dart';

extension SQLEXTDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}

extension CLMediaDB on CLMedia {
  static CLMedia getById(
    Database db,
    int itemId, {
    required String? pathPrefix,
  }) {
    final Map<String, dynamic> map =
        db.select('SELECT * FROM Item WHERE id = ?', [itemId]).first;
    return CLMedia.fromMap(map, pathPrefix: pathPrefix);
  }

  static CLMedia? getByMD5(
    Database db,
    String md5String, {
    required String? pathPrefix,
  }) {
    final Map<String, dynamic>? map = db.select(
      'SELECT * FROM Item WHERE md5String = ?',
      [md5String],
    ).firstOrNull;
    if (map == null) return null;
    return CLMedia.fromMap(map, pathPrefix: pathPrefix);
  }

  static List<CLMedia> getAll(Database db, {String pathPrefix = ''}) {
    final List<Map<String, dynamic>> maps = db.select('SELECT * FROM Item '
        ' ORDER BY Item.updatedDate DESC');
    return maps.map((e) => CLMedia.fromMap(e, pathPrefix: pathPrefix)).toList();
  }

  CLMedia upsert(
    Database db, {
    required String? pathPrefix,
  }) {
    final String updatedPath;
    if (type.isFile) {
      final String removeString;
      if (pathPrefix?.endsWith('/') ?? true) {
        removeString = pathPrefix ?? '';
      } else {
        removeString = '$pathPrefix/';
      }
      updatedPath =
          pathPrefix != null ? path.replaceFirst(removeString, '') : path;
      if (!updatedPath.startsWith('keep_it/$collectionId')) {
        throw Exception('Media must be keep under keep_it dir ');
      }
    } else {
      updatedPath = path;
    }

    if (id != null) {
      db.execute(
        'UPDATE  Item SET path = ?, '
        'ref = ?, collection_id = ?, type=?, originalDate=?, md5String=? '
        'WHERE id = ?',
        [
          updatedPath,
          ref,
          collectionId,
          type.name,
          originalDate.toSQL(),
          md5String,
          id,
        ],
      );
      return getById(db, id!, pathPrefix: pathPrefix);
    }
    db.execute(
      'INSERT  INTO Item (path, '
      'ref, collection_id, type, originalDate, md5String) '
      'VALUES (?, ?, ?, ?, ?, ?) ',
      [
        updatedPath,
        ref,
        collectionId,
        type.name,
        originalDate.toSQL(),
        md5String,
      ],
    );
    return getById(db, db.lastInsertRowId, pathPrefix: pathPrefix);
  }

  void delete(Database db) {
    if (id == null) return;
    db.execute('DELETE FROM Item WHERE id = ?', [id]);
  }

  static List<CLMedia> getByCollectionId(
    Database db,
    int collectionId, {
    required String? pathPrefix,
  }) {
    final List<Map<String, dynamic>> maps = db.select(
      'SELECT * FROM Item WHERE collection_id = ?'
      ' ORDER BY Item.updatedDate DESC',
      [collectionId],
    );

    return maps.map((e) => CLMedia.fromMap(e, pathPrefix: pathPrefix)).toList();
  }

  static List<CLMedia> getByTagId(
    Database db,
    int tagId, {
    required String? pathPrefix,
  }) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Item.*
      FROM Item
      JOIN Collection ON Item.collection_id = Collection.id
      JOIN TagCollection ON Collection.id = TagCollection.collection_id
      WHERE TagCollection.tag_id = $tagId
      ORDER BY Item.updatedDate DESC
    ''',
    );

    return maps.map((e) => CLMedia.fromMap(e, pathPrefix: pathPrefix)).toList();
  }

  static String relativePath(String path, DeviceDirectories directories) {
    if (path.startsWith(directories.container.path)) {
      return path.replaceFirst(directories.container.path, '');
    }
    // Paths outside the container, lets keep the absoulte path
    return path;
  }
}
