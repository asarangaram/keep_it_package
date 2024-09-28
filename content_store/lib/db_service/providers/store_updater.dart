import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;

import '../models/store_updater.dart';
import '../../storage_service/providers/directories.dart';

class StoreUpdaterNotifier extends AsyncNotifier<StoreUpdater> {
  @override
  FutureOr<StoreUpdater> build() async {
    //  final store = await ref.watch(storeProvider.future);
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
    final db = deviceDirectories.db;
    const dbName = 'keepIt.db';
    final fullPath = p.join(db.pathString, dbName);

    final store = await createStoreInstance(
      fullPath,
      onReload: () {},
    );
    return StoreUpdater(
      store: store,
      directories: directories,
    );
  }
}

final storeUpdaterProvider =
    AsyncNotifierProvider<StoreUpdaterNotifier, StoreUpdater>(
  StoreUpdaterNotifier.new,
);
