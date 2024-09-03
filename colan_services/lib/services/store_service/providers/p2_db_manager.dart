import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';

import '../../storage_service/providers/directories.dart';
import '../models/store_manager.dart';

/* final storeProvider = FutureProvider<Store>((ref) async {
  final DeviceDirectories = await ref.watch(DeviceDirectoriesProvider.future);
  final db = DeviceDirectories.directories.db;
  final fullPath = join(db.pathString, DeviceDirectories.dbName);

  final storeInstance = await createStoreInstance(
    fullPath,
    onReload: ref.invalidateSelf,
  );
  ref.onDispose(storeInstance.dispose);
  return storeInstance;
}); */

class StoreNotifier extends StateNotifier<AsyncValue<StoreManager>> {
  StoreNotifier(this.ref) : super(const AsyncValue.loading()) {
    create();
  }
  final Ref ref;
  late final Store? storeInstance;
  String get dbName => 'keepIt.db';

  Future<void> create() async {
    final deviceDirectories = await ref.watch(deviceDirectoriesProvider.future);

    final db = deviceDirectories.db;
    final fullPath = join(db.pathString, dbName);

    storeInstance = await createStoreInstance(
      fullPath,
      onReload: ref.invalidateSelf,
    );
    if (storeInstance != null) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return StoreManager(
          store: storeInstance!,
          deviceDirectories: deviceDirectories,
        );
      });
    }
  }

  @override
  void dispose() {
    storeInstance?.dispose();
    super.dispose();
  }
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, AsyncValue<StoreManager>>((ref) {
  final notifier = StoreNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
