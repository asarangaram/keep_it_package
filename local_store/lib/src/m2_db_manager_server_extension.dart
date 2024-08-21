import 'package:http/http.dart' as http;

import 'cl_server.dart';
import 'm2_db_manager.dart';
import 'm4_db_writer_server_extension.dart';

extension DBManagerServerExt on DBManager {
  Future<SyncStatus> push() async {
    /* final updatedCollections =  */ await dbReader
        .locallyModifiedCollections();
    if ((await server?.hasConnection()) ?? false) {
    } else {
      throw Exception('Server not found');
    }
    throw UnimplementedError();
  }

  Future<SyncStatus> pull({
    http.Client? client,
  }) async {
    await db.writeTransaction((tx) async {
      final res =
          await dbWriter.pullCollection(tx, server: server, client: client);
      if (res != SyncStatus.success) {
        return res;
      }
    });
    return SyncStatus.success;
  }
}
