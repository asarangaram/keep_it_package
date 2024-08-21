import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm4_db_writer.dart';

extension DBWRiterServerExt on DBWriter {
  Future<SyncStatus> pullCollection(
    SqliteWriteContext tx, {
    required CLServer server,
    http.Client? client,
  }) async {
    if (!await server.hasConnection(client: client)) {
      return SyncStatus.serverNotReachable;
    }
    final collectionJSON =
        await server.getEndpoint('/collection', client: client);
    final collections = Collections.fromJson(collectionJSON);
    final updated = <Collection>[];
    for (final collection in collections.entries) {
      try {
        updated.add(
          await upsertCollection(
            tx,
            collection.copyWith(
              serverUID: server.id,
              locallyModified: false,
            ),
          ),
        );
      } catch (e) {
        /** */
      }
    }
    if (updated.length == collections.entries.length) {
      return SyncStatus.success;
    }
    return SyncStatus.partial;
  }
}
