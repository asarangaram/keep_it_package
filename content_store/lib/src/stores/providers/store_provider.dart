import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';
import 'local_store.dart';

class StoreNotifier extends FamilyAsyncNotifier<CLStore, StoreURL> {
  @override
  FutureOr<CLStore> build(StoreURL arg) async {
    final storeURL = arg;
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final scheme = storeURL.scheme; // local or https

    final store = switch (scheme) {
      'local' => await ref.watch(localStoreProvider(storeURL).future),
      _ => throw Exception('Unexpected')
    };
    return CLStore(store: store, tempFilePath: directories.temp.pathString);
  }
}

final storeProvider =
    AsyncNotifierProviderFamily<StoreNotifier, CLStore, StoreURL>(
        StoreNotifier.new);
