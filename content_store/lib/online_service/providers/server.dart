import 'dart:async';

import 'package:content_store/extensions/list_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/providers/store_updater.dart';
import '../models/cl_server.dart';
import '../models/server.dart';
import 'downloader.dart';
import 'media_analyse_mixin.dart';
import 'media_sync_mixin.dart';

class ServerNotifier extends StateNotifier<Server>
    with MediaSyncMixIn, MediaAnalyseMixin {
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

  Future<void> _sync(CLServer server) async {
    final updater = await storeUpdater;
    await mediaSync(
      await analyse(await serverItemsMap, await localItems),
      server: server,
      updater: updater,
      downloader: downloader,
    ).then((value) {
      updater.store.reloadStore();
    });
  }

  void checkStatus() {
    if (state.isRegistered) {
      state.identity!.hasConnection().then((isOnline) {
        currState = state.copyWith(isOffline: !isOnline);
      });
    }
    return;
  }

  Future<List<CLMedia>> get localItems async {
    final store = (await storeUpdater).store;
    final q = store.reader.getQuery<CLMedia>(DBQueries.mediaSyncQuery);
    return (await store.reader.readMultiple(q)).nonNullableList;
  }

  Future<List<Map<String, dynamic>>> get serverItemsMap async {
    final serverItemsMap = await state.identity!.downloadMediaInfo();
    for (final serverEntry in serverItemsMap) {
      /// There are scenarios when the collections are not synced
      /// fully, we may end up creating one. However, other details for
      /// the newly created collection is not available at this stage, and
      /// we may need to fetch from server if needed. [KNOWN_ISSUE]
      await updateCollectionId(serverEntry, updater: await storeUpdater);
    }
    return serverItemsMap;
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
