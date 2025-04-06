import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;

import '../../storage_service/providers/directories.dart';
import 'package:content_store/store/lib/src/models/local_store.dart';
import 'store_query_result.dart';

class StoreUpdaterNotifier extends AsyncNotifier<TheStore> {
  @override
  FutureOr<TheStore> build() async {
    //  final store = await ref.watch(storeProvider.future);
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);
    final db = deviceDirectories.db;
    const dbName = 'keepIt.db';
    final fullPath = p.join(db.pathString, dbName);

    final store = await createSQLiteDBInstance(
      fullPath,
      onReload: () {
        ref.read(refreshReaderProvider.notifier).state =
            DateTime.now().toIso8601String();
      },
    );
    return TheStore(
      store: store,
      downloadDir: directories.download.pathString,
      tempDir: directories.download.pathString,
    );
  }
}

final storeUpdaterProvider =
    AsyncNotifierProvider<StoreUpdaterNotifier, TheStore>(
  StoreUpdaterNotifier.new,
);
