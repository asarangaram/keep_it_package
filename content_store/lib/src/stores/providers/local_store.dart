import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../../storage_service/providers/directories.dart';
import '../refresh_cache.dart';

final dbProvider = FutureProvider<DBModel>((ref) async {
  final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
  const dbName = 'keepIt.db';
  final fullPath = p.join(deviceDirectories.db.pathString, dbName);

  return createSQLiteDBInstance(
    fullPath,
    onReload: () {
      ref.read(refreshReaderProvider.notifier).state =
          DateTime.now().toIso8601String();
    },
  );
});

final localStoreProvider = FutureProvider<EntityStore>((ref) async {
  //final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
  final db = await ref.watch(dbProvider.future);
  return createEntityStore(db, 'local');
});
