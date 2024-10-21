import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/db_service/models/store_updter_ext_store.dart';
import 'package:content_store/extensions/list_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/providers/store_updater.dart';
import '../../extensions/ext_cl_media.dart';
import '../models/cl_server.dart';
import '../models/media_change_tracker.dart';
import '../models/server.dart';
import '../models/server_upload_entity.dart';
import 'downloader.dart';
import 'server_sync_mixin.dart';

class ServerNotifier extends StateNotifier<Server> with MediaSyncMixIn {
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
          identity: () => identity,
          workingOffline: workingOffline,
        ),
      );
    }

    // Read Workoffline from sharedPReference and update
  }

  Server get currState => state;

  set currState(Server val) {
    state = val;
    log(state.toString());
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
    if (state.isRegistered) {
      final isOnline = (await server.identity?.hasConnection()) ?? false;
      currState = state.copyWith(isOffline: !isOnline);
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
        if (state.isRegistered) {
          server.identity!.hasConnection().then((isOnline) {
            currState = state.copyWith(isOffline: !isOnline);
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      timer?.cancel();
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

  void sync() {
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
        setState(state.copyWith(isSyncing: false));
        log('sync Completed');
      }),
    );
  }

  void checkStatus() {
    if (state.isRegistered) {
      state.identity!.hasConnection().then((isOnline) {
        currState = state.copyWith(isOffline: !isOnline);
      });
    }
    return;
  }

  Future<void> _sync(CLServer server) async {
    final serverItemsMap = await state.identity!.downloadMediaInfo();
    for (final serverEntry in serverItemsMap) {
      /// There are scenarios when the collections are not synced
      /// fully, we may end up creating one. However, other details for
      /// the newly created collection is not available at this stage, and
      /// we may need to fetch from server if needed. [KNOWN_ISSUE]
      await updateCollectionId(serverEntry, updater: await storeUpdater);
    }
    final store = (await storeUpdater).store;
    final q = store.reader.getQuery<CLMedia>(DBQueries.mediaSyncQuery);
    final localItems = (await store.reader.readMultiple(q)).nonNullableList;

    final trackers = await analyse(serverItemsMap, localItems);
    log(' ${trackers.length} items need sync');
    await mediaSync(
      trackers,
      server: server,
      updater: await storeUpdater,
      downloader: downloader,
    );

    (await storeUpdater).store.reloadStore();
  }

  static Future<List<MediaChangeTracker>> analyse(
    List<Map<String, dynamic>> serverItemsMap,
    List<CLMedia> localItems,
  ) async {
    final trackers = <MediaChangeTracker>[];
    log('items in local: ${localItems.length}');
    log('items in Server: ${serverItemsMap.length}');
    for (final serverEntry in serverItemsMap) {
      final localEntry = localItems
          .where(
            (e) =>
                e.serverUID == serverEntry['serverUID'] ||
                e.md5String == serverEntry['md5String'],
          )
          .firstOrNull;

      final tracker = MediaChangeTracker(
        current: localEntry,
        update: StoreExtCLMedia.mediaFromServerMap(localEntry, serverEntry),
      );

      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
      if (localEntry != null) {
        localItems.remove(localEntry);
      }
    }
    // For remaining items
    trackers.addAll(
      localItems.map((e) => MediaChangeTracker(current: e, update: null)),
    );
    return trackers;
  }

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
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service | Server',
    ); */
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, Server>((ref) {
  final storeUpdater = ref.watch(storeUpdaterProvider.future);
  final downloaderNotifier = ref.watch(downloaderProvider.notifier);
  final notifier = ServerNotifier(storeUpdater, downloaderNotifier);
  ref.listenSelf((prev, curr) {
    if (curr.canSync && !(prev?.canSync ?? false)) {
      notifier.sync();
    }
  });
  return notifier;
});
