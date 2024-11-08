import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/providers/store_updater.dart';
import '../models/cl_server.dart';
import '../models/server.dart';
import '../models/sync_module/collection.dart';
import '../models/sync_module/media.dart';
import 'downloader.dart';

class ServerNotifier extends StateNotifier<Server> {
  ServerNotifier(this.storeUpdater, this.downloader) : super(const Server()) {
    _initialize();
  }

  Timer? timer;
  Future<StoreUpdater> storeUpdater;
  DownloaderNotifier downloader;

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');
    if (myServerJSON != null) {
      final identity = CLServer.fromJson(myServerJSON);
      log('Server found from history. $identity');
      final workingOffline = prefs.getBool('workingOffline');

      await setState(
        state.copyWith(
          previousIdentity: () => identity,
          identity: () => identity,
          workingOffline: workingOffline,
        ),
      );
    }

    // Read Workoffline from sharedPReference and update
  }

  Server get currState => state;

  set currState(Server val) {
    if (state != val) {
      log('state updated, ${state.hashCode} ${val.hashCode}');
      state = val;
      log(state.toString());
    }
  }

  Future<void> setState(Server server) async {
    currState = server;
    final prefs = await SharedPreferences.getInstance();
    if (state.identity != null) {
      await prefs.setString('myServer', state.identity!.toJson());
    } else {
      await prefs.remove('myServer');
    }
    await prefs.setBool('workingOffline', state.workingOffline);
    timer?.cancel();
    if (state.isRegistered) {
      final liveStatus = await server.identity?.getServerLiveStatus();
      currState = state.copyWith(
        isOffline: liveStatus == null,
        identity: () => liveStatus,
      );
      timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (state.isRegistered) {
          server.identity!.getServerLiveStatus().then((liveStatus) {
            currState = state.copyWith(
              isOffline: liveStatus == null,
              identity: () => liveStatus,
            );
          });
        } else {
          timer?.cancel();
          timer = null;
        }
      });
    } else {
      timer = null;
    }
  }

  void register(CLServer candidate) {
    if (state.isRegistered) {
      if (state.identity != candidate) {
        log("can't register ($candidate) as "
            'another server( ${state.identity}) is registered');
      }
      return;
    }
    setState(state.copyWith(identity: () => candidate))
        .then((_) => log('server registered $state'));
  }

  void deregister() {
    if (state.isRegistered) {
      setState(state.copyWith(identity: () => null));
    }
  }

  void goOnline() => setState(state.copyWith(workingOffline: false));

  void workOffline() => setState(state.copyWith(workingOffline: true));
  void autoSync({bool isServerChange = false}) {
    log('autoSync requested');
    if (!isServerChange) {
      coreSync();
    }
    // Future.delayed(const Duration(milliseconds: 300), coreSync);
  }

  void manualSync() {
    log('manualSync requested');
    coreSync();
  }

  void instantSync() {
    log('instantSync requested');
    coreSync();
  }

  void coreSync() {
    if (state.isSyncing) {
      log('server is already syncing. ignoring duplicate request');
      return;
    }
    if (!state.canSync) {
      log("server can't sync");
      return;
    }
    log('sync starting');
    setState(state.copyWith(isSyncing: true)).then(
      (_) => _sync(state.identity!).then((_) {
        onSyncDone();
        log('sync Completed');
      }),
    );
  }

  Future<void> onSyncDone() async {
    final liveStatus = await state.identity!.getServerLiveStatus();
    await setState(
      state.copyWith(
        isSyncing: false,
        previousIdentity: () => liveStatus,
      ),
    );
  }

  Future<void> _sync(CLServer server) async {
    try {
      final updater = await storeUpdater;
      await (await collectionSyncModule).sync();

      final mediaSyncModule = await this.mediaSyncModule(
        await updater.store.reader.collectionsToSync,
      );

      await mediaSyncModule.sync();

      updater.store.reloadStore();
    } catch (e) {
      log('Sync error: $e');
      /** */
    }
  }

  Future<void> _downloadMediaFile(CLServer server, CLMedia media) async {
    try {
      final updater = await storeUpdater;
      final collectionsToSync = await updater.store.reader.collectionsToSync;

      final mediaSyncModule = await this.mediaSyncModule(
        await updater.store.reader.collectionsToSync,
      );
      final syncedCollections =
          collectionsToSync.where((e) => e.haveItOffline).toList();

      await mediaSyncModule.downloadMediaFile(
        media,
        isCollectionSynced: syncedCollections
                .where((e) => e.id == media.collectionId)
                .firstOrNull !=
            null,
      );
      updater.store.reloadStore();
      //await _sync(server);
    } catch (e) {
      log('Sync error: $e');
      /** */
    }
  }

  void downloadMediaFile(CLMedia media) {
    if (state.isSyncing) {
      log('server is already syncing. ignoring duplicate request');
      return;
    }
    if (!state.canSync) {
      log("server can't sync");
      return;
    }
    log('sync starting');
    setState(state.copyWith(isSyncing: true)).then(
      (_) => _downloadMediaFile(state.identity!, media).then((_) {
        setState(state.copyWith(isSyncing: false));
        log('sync Completed');
      }),
    );
  }

  Future<CollectionSyncModule> get collectionSyncModule async =>
      CollectionSyncModule(state.identity!, await storeUpdater, downloader);

  Future<MediaSyncModule> mediaSyncModule(List<Collection> collections) async =>
      MediaSyncModule(
        state.identity!,
        await storeUpdater,
        downloader,
        collections,
      );

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  static void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service | Server',
    );
  }

  Future<bool> onDeleteMediaLocalCopy(CLMedia media) async {
    final updater = await storeUpdater;
    await updater.mediaUpdater.deleteLocalCopy(media, shouldRefresh: false);
    instantSync();
    return true;
  }

  Future<bool> onKeepMediaOffline(CLMedia media) async {
    final updater = await storeUpdater;
    final mediaInDB = await updater.mediaUpdater
        .markHaveItOffline(media, shouldRefresh: false);
    if (mediaInDB != null) {
      downloadMediaFile(mediaInDB);
    }

    return true;
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, Server>((ref) {
  final storeUpdater = ref.watch(storeUpdaterProvider.future);
  final downloaderNotifier = ref.watch(downloaderProvider.notifier);
  final notifier = ServerNotifier(storeUpdater, downloaderNotifier);
  ref.listenSelf((prev, curr) {
    if (curr.canSync && !(prev?.canSync ?? false)) {
      notifier.autoSync();
    }
  });
  return notifier;
});
