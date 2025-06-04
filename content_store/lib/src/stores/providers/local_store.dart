import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../../storage_service/providers/directories.dart';

final dbProvider = FutureProvider<DBModel>((ref) async {
  final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
  const dbName = 'keepIt.db';
  final fullPath = p.join(deviceDirectories.db.pathString, dbName);

  return createSQLiteDBInstance(
    fullPath,
  );
});

final localStoreProvider = FutureProvider<EntityStore>((ref) async {
  final db = await ref.watch(dbProvider.future);
  final directories = await ref.watch(deviceDirectoriesProvider.future);
  return createEntityStore(
    db,
    'local',
    mediaPath: directories.media.pathString,
    previewPath: directories.media.pathString,
  );
});
