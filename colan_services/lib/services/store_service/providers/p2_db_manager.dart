import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';

import '../../storage_service/providers/directories.dart';
import '../models/store_manager.dart';

final storeProvider = FutureProvider<StoreManager>((ref) async {
  final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);

  final db = deviceDirectories.db;
  const dbName = 'keepIt.db';
  final fullPath = join(db.pathString, dbName);

  final storeInstance = await createStoreInstance(
    fullPath,
    onReload: ref.invalidateSelf,
  );

  final storeManager = StoreManager(
    store: storeInstance,
    deviceDirectories: deviceDirectories,
  );
  ref.onDispose(storeManager.store.dispose);
  return storeManager;
});
