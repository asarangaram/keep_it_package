import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart';

extension SQLEXTDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}

extension ExtItemInDB on CLMedia {
  static CLMedia getByID(
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

  int dbUpsert(
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
      if (!updatedPath.startsWith('keep_it/')) {
        throw Exception('Media must be keep under keep_it dir ');
      }
    } else {
      updatedPath = path;
    }

    if (id != null) {
      db.execute(
        'UPDATE OR IGNORE Item SET path = ?, '
        'ref = ?, collection_id = ? type=? originalDate=? md5String=? '
        'WHERE id = ?',
        [
          updatedPath,
          ref,
          collectionId,
          type,
          originalDate.toSQL(),
          md5String,
          id,
        ],
      );
      return id!;
    }
    db.execute(
      'INSERT OR IGNORE INTO Item (path, '
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
    return db.lastInsertRowId;
  }

  void dbDelete(Database db) {
    if (id == null) return;
    db.execute('DELETE FROM Item WHERE id = ?', [id]);
  }

  static List<CLMedia> dbGetByCollectionId(
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

  /* CLMedia toCLMedia({String pathPrefix = ''}) {
    final p = FileHandler.join(pathPrefix, this.path);
    return switch (type) {
      CLMediaType.image => CLMediaImage(path: p, ref: ref),
      CLMediaType.video => CLMediaVideo(path: p, ref: ref),
      _ => CLMedia(
          path: p,
          type: type,
        )
    }; 
  }*/

  /* static Future<ItemInDB> fromCLMedia(
    CLMedia media, {
    required int collectionId,
  }) async {
    if (![CLMediaType.video, CLMediaType.image].contains(media.type)) {
      return ItemInDB(
        collectionId: collectionId,
        path: media.path,
        type: media.type,
      );
    }

    return ItemInDB(
      collectionId: collectionId,
      path: await (await media.copy(
        toDir: path.join('keep_it', 'collection_$collectionId'),
      ))
          .relativePathFuture,
      type: media.type,
      ref: media.ref,
    );
  } */
}
