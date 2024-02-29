import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_async/sqlite_async.dart';

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
}
