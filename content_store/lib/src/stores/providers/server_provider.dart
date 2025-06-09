import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_store/online_store.dart';

import 'package:store/store.dart';

class ServerNotifier extends FamilyAsyncNotifier<CLServer, StoreURL> {
  Timer? timer;
  @override
  FutureOr<CLServer> build(StoreURL arg) async {
    final clServer = await CLServer(storeURL: arg).getServerLiveStatus();

    timer = Timer.periodic(const Duration(seconds: 5), monitorServer);

    ref.onDispose(() {
      timer?.cancel();
      timer = null;
    });

    state = AsyncData(clServer);
    return clServer;
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

  Future<void> monitorServer(Timer _) async {
    final clServer = await CLServer(storeURL: arg).getServerLiveStatus();
    final server = state.value;

    if (server != clServer) {
      state = AsyncData(clServer);
    }
  }
}

final serverProvider =
    AsyncNotifierProviderFamily<ServerNotifier, CLServer, StoreURL>(
        ServerNotifier.new);
