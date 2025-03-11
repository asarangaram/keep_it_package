import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cl_server.dart';
import '../models/server.dart';
import 'scanner.dart';

class ServerNotifier extends StateNotifier<ServerBasic> {
  ServerNotifier() : super(const ServerBasic()) {
    _initialize();
  }

  Timer? timer;

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

  ServerBasic get currState => state;

  set currState(ServerBasic val) {
    if (state != val) {
      log('state updated, ${state.hashCode} ${val.hashCode}');
      state = val;
      log(state.toString());
    }
  }

  Future<void> setState(ServerBasic server) async {
    currState = server;
    final prefs = await SharedPreferences.getInstance();
    if (state.identity != null) {
      await prefs.setString('myServer', state.identity!.toJson());
    } else {
      await prefs.remove('myServer');
    }
    await prefs.setBool('workingOffline', state.workingOffline);
    await updateStatus();
  }

  Future<void> updateStatus() async {
    timer?.cancel();
    if (state.isRegistered) {
      final liveStatus = await state.identity?.getServerLiveStatus();
      currState = state.copyWith(
        isOffline: liveStatus == null,
      );
      timer = Timer.periodic(const Duration(seconds: 15), (_) {
        if (state.isRegistered) {
          state.identity!.getServerLiveStatus().then((liveStatus) {
            currState = state.copyWith(
              isOffline: liveStatus == null,
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
}

final serverProvider =
    StateNotifierProvider<ServerNotifier, ServerBasic>((ref) {
  final notifier = ServerNotifier();
  // ignore: deprecated_member_use
  ref.listenSelf((prev, curr) {
    ServerNotifier.log(curr.toString());
  });
  ref.listen(networkScannerProvider, (prev, curr) {
    if (prev?.lanStatus != curr.lanStatus) {
      notifier.updateStatus();
    }
  });
  return notifier;
});
