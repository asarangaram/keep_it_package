import 'dart:async';

import 'package:content_store/src/storage_service/providers/directories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/store_updater.dart';
import 'db_store.dart';

class StoreUpdaterNotifier extends AsyncNotifier<StoreUpdater> {
  @override
  FutureOr<StoreUpdater> build() async {
    final store = await ref.watch(storeProvider.future);
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    return StoreUpdater(store, directories);
  }

  void onRefresh() {}
}

final storeUpdaterProvider =
    AsyncNotifierProvider<StoreUpdaterNotifier, StoreUpdater>(
  StoreUpdaterNotifier.new,
);
