import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:online_store/online_store.dart';
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';

class StoreNotifier extends FamilyAsyncNotifier<CLStore, StoreURL> {
  @override
  FutureOr<CLStore> build(StoreURL arg) async {
    final storeURL = arg;
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final scheme = storeURL.scheme; // local or https

    final store = switch (scheme) {
      'local' => await createEntityStore(
          storeURL,
          storePath: directories.db.pathString,
        ),
      'http' => await createOnlineEntityStore(
          storeURL,
          storePath: directories.db.pathString,
        ),
      'https' => await createEntityStore(
          storeURL,
          storePath: directories.db.pathString,
        ),
      _ => throw Exception('Unexpected')
    };
    return CLStore(store: store, tempFilePath: directories.temp.pathString);
  }
}

final storeProvider =
    AsyncNotifierProviderFamily<StoreNotifier, CLStore, StoreURL>(
        StoreNotifier.new);
