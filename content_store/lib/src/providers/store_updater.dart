import 'dart:async';

import 'package:content_store/src/providers/server.dart';
import 'package:content_store/src/storage_service/providers/directories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/store_updater.dart';
import 'db_store.dart';
import 'downloader_provider.dart';

class StoreUpdaterNotifier extends AsyncNotifier<StoreUpdater> {
  @override
  FutureOr<StoreUpdater> build() async {
    final store = await ref.watch(storeProvider.future);
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final server = ref.watch(serverProvider);
    final downloader = ref.watch(downloaderProvider);
    return StoreUpdater(
      store: store,
      directories: directories,
      server: server.identity,
      downloader: downloader,
    );
  }

/*   sync() {
    state.whenOrNull(data: (storeUpdater) {
      state = state
    });
  } */

  void onRefresh() {}
}

final storeUpdaterProvider =
    AsyncNotifierProvider<StoreUpdaterNotifier, StoreUpdater>(
  StoreUpdaterNotifier.new,
);
