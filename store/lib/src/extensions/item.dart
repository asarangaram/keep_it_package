import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite3/sqlite3.dart';

extension ExtItemInDB on CLMedia {
  static CLMedia getByID(Database db, int itemId, {String prefix = ''}) {
    final Map<String, dynamic> map =
        db.select('SELECT * FROM Item WHERE id = ?', [itemId]).first;
    return CLMedia.fromMap(map);
  }

  static List<CLMedia> getAll(Database db) {
    final List<Map<String, dynamic>> maps = db.select('SELECT * FROM Item '
        ' ORDER BY Item.updatedDate DESC');
    return maps.map(CLMedia.fromMap).toList();
  }

  int dbUpsert(
    Database db,
  ) {
    if (id != null) {
      db.execute(
        'UPDATE OR IGNORE Item SET path = ?, '
        'ref = ?, collection_id = ? type=? WHERE id = ?',
        [path, ref, collectionId, type, id],
      );
    }
    db.execute(
      'INSERT OR IGNORE INTO Item (path, '
      'ref, collection_id, type) VALUES (?, ?, ?, ?) ',
      [path, ref, collectionId, type.name],
    );
    return db.lastInsertRowId;
  }

  void dbDelete(Database db) {
    if (id == null) return;
    db.execute('DELETE FROM Item WHERE id = ?', [id]);
  }

  static List<CLMedia> dbGetByCollectionId(Database db, int collectionId) {
    final List<Map<String, dynamic>> maps = db.select(
      'SELECT * FROM Item WHERE collection_id = ?'
      ' ORDER BY Item.updatedDate DESC',
      [collectionId],
    );

    return maps.map(CLMedia.fromMap).toList();
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
