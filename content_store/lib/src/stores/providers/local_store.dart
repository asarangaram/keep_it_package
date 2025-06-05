import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../../storage_service/providers/directories.dart';

final FutureProviderFamily<DBModel, String> _dbProvider =
    FutureProvider.family<DBModel, String>((ref, dbName) async {
  final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
  final fullPath = p.join(deviceDirectories.db.pathString, dbName);
  return createSQLiteDBInstance(fullPath);
});

final FutureProviderFamily<EntityStore, String> localStoreProvider =
    FutureProvider.family<EntityStore, String>((ref, url) async {
  final uri = Uri.parse(url);
  final scheme = uri.scheme; // local or https
  if (scheme != 'local') {
    throw Exception('scheme $scheme is not supported by local Store');
  }
  final name = uri.host.isNotEmpty ? uri.host : uri.path;
  final db = await ref.watch(_dbProvider('$name.db').future);
  final directories = await ref.watch(deviceDirectoriesProvider.future);

  final mediaPath = p.join(directories.media.pathString, name);
  final previewPath = p.join(directories.thumbnail.pathString, name);
  if (!Directory(mediaPath).existsSync()) {
    Directory(mediaPath).createSync(recursive: true);
  }
  if (!Directory(previewPath).existsSync()) {
    Directory(previewPath).createSync(recursive: true);
  }
  return createEntityStore(
    db,
    url,
    mediaPath: mediaPath,
    previewPath: previewPath,
  );
});
