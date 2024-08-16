import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:store/store.dart';
import '../cl_server.dart';
import 'm2_db_manager.dart';

Future<Store> createServerCache({
  required String dbDir,
  required bool? isOnline,
  required void Function() onReload,
  required CLServer? server,
}) async {
  final File dbFile;
  if (server == null) {
    dbFile = File(p.join(dbDir, 'offline_db..sqlite.db'));
  } else if (server.id == null) {
    throw Exception('Server Id is required');
  } else {
    dbFile = File(p.join(dbDir, '${server.id}.sqlite.db'));
  }
  if (!dbFile.parent.existsSync()) {
    dbFile.parent.createSync(recursive: true);
  }

  final instance = DBManager.createInstances(
    dbpath: dbFile.path,
    onReload: onReload,
    server: server,
    isOnline: isOnline,
  );

  return instance;
}
