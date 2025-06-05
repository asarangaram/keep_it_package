import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';
import 'local_store.dart';

class StoreNotifier extends FamilyAsyncNotifier<CLStore, String> {
  @override
  FutureOr<CLStore> build(String arg) async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final url = ref.watch(activeStoreURLProvider);
    final uri = Uri.parse(url);
    final scheme = uri.scheme; // local or https

    final store = switch (scheme) {
      'local' => await ref.watch(localStoreProvider(url).future),
      _ => throw Exception('Unexpected')
    };
    return CLStore(store: store, tempFilePath: directories.temp.pathString);
  }
}

final storeProvider =
    AsyncNotifierProviderFamily<StoreNotifier, CLStore, String>(
        StoreNotifier.new);

final activeStoreURLProvider = StateProvider<String>((ref) {
  return 'local://default';
});
