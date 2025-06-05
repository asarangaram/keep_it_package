import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:store/store.dart';

import '../../../../storage_service/providers/directories.dart';

final FutureProviderFamily<EntityStore, StoreURL> localStoreProvider =
    FutureProvider.family<EntityStore, StoreURL>((ref, storeURL) async {
  final directories = await ref.watch(deviceDirectoriesProvider.future);

  switch (storeURL.scheme) {
    case 'local':
      return createEntityStore(storeURL, storePath: directories.db.pathString);
    default:
      throw Exception(
          'scheme ${storeURL.scheme} is not supported by local Store');
  }
});
