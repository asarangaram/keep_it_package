import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../storage_service/providers/directories.dart';

final storeProvider = FutureProvider<Store>((ref) async {
  final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
  final db = deviceDirectories.db;
  const dbName = 'keepIt.db';
  final fullPath = p.join(db.pathString, dbName);

  return createStoreInstance(
    fullPath,
    onReload: () {},
  );
});
