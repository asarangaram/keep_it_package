import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension ExtDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}

extension CollectionDB on Collection {
  Future<void> deleteCollection(SqliteWriteContext tx) async {
    if (id == null) return;
    await tx.execute(
      'DELETE FROM TagCollection WHERE collection_id = ?',
      [id],
    );
    await tx.execute(
      'DELETE FROM Collection WHERE id = ?',
      [id],
    );
    await tx.execute(
      'DELETE FROM Item WHERE collection_id = ?',
      [id],
    );
  }

  Future<void> removeTag(SqliteWriteContext tx, int tagId) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [tagId, id],
      );
    }
  }

  Future<void> removeTags(SqliteWriteContext tx, List<int> tagIds) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [
          for (final tagId in tagIds) [tagId, id],
        ],
      );
    }
  }

  Future<void> removeAllTags(SqliteWriteContext tx) async {
    if (id != null) {
      await tx.execute(
        'DELETE FROM TagCollection '
        'WHERE collection_id = ? ',
        [id],
      );
    }
  }
}

bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
