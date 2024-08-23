import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm4_db_writer.dart';

extension DBWRiterServerExt on DBWriter {
  Future<DBSyncStatus> pullMedia(
    SqliteWriteContext tx, {
    required CLServer server,
    http.Client? client,
  }) async {
    if (!await server.hasConnection(client: client)) {
      return DBSyncStatus.serverNotReachable;
    }
    final mediaJSON =
        await server.getEndpoint('/media?type=image', client: client);
    final medias = CLMedias.fromJson(mediaJSON);
    final updated = <CLMedia>[];
    for (final media in medias.entries) {
      try {
        updated.add(
          await upsertMedia(
            tx,
            media,
          ),
        );
      } catch (e) {
        /** */
      }
    }
    if (updated.length == medias.entries.length) {
      return DBSyncStatus.success;
    }
    return DBSyncStatus.partial;
  }
}
