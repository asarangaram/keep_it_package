import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'db_command.dart';
import 'db_extension_on_map.dart';

@immutable
class DBBatchCommand {
  const DBBatchCommand(this.commands);

  factory DBBatchCommand.upsertFromList(
    List<Map<String, dynamic>> list, {
    required String table,
    required List<int> Function(List<int> id) getPresentIdList,
    bool autoIncrementId = true,
    bool ignore = false,
  }) {
    final idsPresent =
        getPresentIdList(list.where((e) => e.hasID).map((e) => e.id!).toList());
    final items2Update = list.where((e) => idsPresent.contains(e.id)).toList();
    final items2insert = list.where((e) => !idsPresent.contains(e.id)).toList();

    return DBBatchCommand([
      ...items2Update.map(
        (e) => DBCommand.updateFromMap(
          e,
          table: table,
        ),
      ),
      ...items2insert.map(
        (e) => DBCommand.insertFromMap(
          e,
          table: table,
          autoIncrementId: autoIncrementId,
          ignore: ignore,
        ),
      ),
    ]);
  }

  factory DBBatchCommand.insertFromList(
    List<Map<String, dynamic>> list, {
    required String table,
    bool autoIncrementId = true,
    bool ignore = false,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.insertFromMap(
              e,
              table: table,
              autoIncrementId: autoIncrementId,
              ignore: ignore,
            ),
          )
          .toList(),
    ).merge();
  }
  factory DBBatchCommand.updateFromList(
    List<Map<String, dynamic>> list, {
    required String table,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.updateFromMap(
              e,
              table: table,
            ),
          )
          .toList(),
    ).merge();
  }
  factory DBBatchCommand.deleteFromList(
    List<Map<String, dynamic>> list, {
    required String table,
    List<String>? identifiers,
  }) {
    return DBBatchCommand(
      list
          .map(
            (e) => DBCommand.deleteFromMap(
              e,
              table: table,
              identifiers: identifiers,
            ),
          )
          .toList(),
    ).merge();
  }

  final List<DBCommand> commands;

  DBBatchCommand merge() {
    final map = <String, DBCommand>{};
    for (final item in commands) {
      map.putIfAbsent(item.sql, () => item).mergeParameters(item);
    }

    return DBBatchCommand(map.values.toList());
  }

  Future<bool> execute(SqliteWriteContext tx) async {
    for (final cmd in commands) {
      if (!await cmd.execute(tx)) return false;
    }
    return true;
  }
}
