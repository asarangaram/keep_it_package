import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;

import '../../storage_service/providers/directories.dart';
import '../models/local_store.dart';
import 'store_query_result.dart';

class StoreUpdaterNotifier extends AsyncNotifier<LocalStore> {
  @override
  FutureOr<LocalStore> build() async {
    //  final store = await ref.watch(storeProvider.future);
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
    final db = deviceDirectories.db;
    const dbName = 'keepIt.db';
    final fullPath = p.join(db.pathString, dbName);

    final store = await createDBStoreInstance(
      fullPath,
      onReload: () {
        ref.read(refreshReaderProvider.notifier).state =
            DateTime.now().toIso8601String();
      },
    );
    return LocalStore(
      store: store,
      directories: directories,
    );
  }
}

final storeUpdaterProvider =
    AsyncNotifierProvider<StoreUpdaterNotifier, LocalStore>(
  StoreUpdaterNotifier.new,
);
