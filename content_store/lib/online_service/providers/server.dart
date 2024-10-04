import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/providers/store_updater.dart';
import '../models/cl_server.dart';
import '../models/server.dart';
import '../models/store_updater_ext_server.dart';

class ServerNotifier extends StateNotifier<Server> {
  ServerNotifier(this.storeUpdater) : super(const Server()) {
    _initialize();
  }

  Timer? timer;
  Future<StoreUpdater> storeUpdater;

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
      (_) => _sync().then((_) {
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

  Future<void> _sync() async {
    final mapList = await state.identity?.downloadMediaInfo();
    if (mapList != null) {
      log('Found ${mapList.length} items in the server');
      return (await storeUpdater).sync(mapList);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void log(
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
}

final serverProvider = StateNotifierProvider<ServerNotifier, Server>((ref) {
  final storeUpdater = ref.watch(storeUpdaterProvider.future);
  final notifier = ServerNotifier(storeUpdater);
  ref.listenSelf((prev, curr) {
    if (curr.canSync && !(prev?.canSync ?? false)) {
      notifier.sync();
    }
  });
  return notifier;
});
