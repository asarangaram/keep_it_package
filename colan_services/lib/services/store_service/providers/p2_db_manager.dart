import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';

final storeProvider = FutureProvider<Store>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbPath = appSettings.directories.database;
  final fullPath = join(dbPath.pathString, appSettings.dbName);
  final server = await ref.watch(serverProvider.future);

  final storeInstance = await createStoreInstance(
    fullPath,
    onReload: ref.invalidateSelf,
    server: server,
  );
  ref.onDispose(storeInstance.dispose);
  return storeInstance;
});

final serverProvider = FutureProvider<CLServer?>((ref) async {
  final server =
      await const CLServer(name: 'udesktop.local', port: 5000).withId();
  return server;
});
