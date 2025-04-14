import 'dart:io';

import 'package:local_store/local_store.dart';
import 'package:minimal_mvn/minimal_mvn.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:store/store.dart';

class LocalStoreNotifier extends MMNotifier<CLStore> {
  LocalStoreNotifier() : super(CLStore()) {
    _initialize();
  }
  void _onLoading() => notify(state.loading());

  void _onData(EntityStore localStore, String tempFilePath) {
    notify(
      state.register(
        store: localStore,
        tempFilePath: tempFilePath,
      ),
    );
  }

  void _onError(String msg) => notify(state.error(msg));

  Future<void> _initialize() async {
    _onLoading();
    try {
      final persistent = await getApplicationSupportDirectory();
      final temporary = await getApplicationCacheDirectory();

      final dbPath =
          p.join(persistent.path, 'keep_it/store/database/keep_it.db');
      final tempDir = p.join(temporary.path, 'keep_it/temp');
      final mediaPath = p.join(persistent.path, 'keep_it/store/media');
      final previewPath = p.join(persistent.path, 'keep_it/store/thumbnails');

      final db = await createSQLiteDBInstance(dbPath);
      final localStore = await createEntityStore(
        db,
        'local',
        mediaPath: mediaPath,
        previewPath: previewPath,
      );
      _onData(localStore, tempDir);
    } catch (e) {
      _onError(e.toString());
    }
  }
}

final localStoreNotifierManager = MMManager<LocalStoreNotifier>(() {
  return LocalStoreNotifier();
});
