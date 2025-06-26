import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_store/online_store.dart';

import 'package:store/store.dart';

class ServerNotifier extends FamilyAsyncNotifier<CLServer, StoreURL>
    with CLLogger {
  @override
  String get logPrefix => 'ServerNotifier';

  Timer? timer;

  @override
  FutureOr<CLServer> build(StoreURL arg) async {
    try {
      final clServer = await CLServer(storeURL: arg).getServerLiveStatus();

      timer = Timer.periodic(const Duration(seconds: 5), monitorServer);

      ref.onDispose(() {
        timer?.cancel();
        timer = null;
      });

      state = AsyncData(clServer);
      return clServer;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> monitorServer(Timer _) async {
    try {
      final clServer = await CLServer(storeURL: arg).getServerLiveStatus();
      final server = state.value;

      if (server != clServer) {
        state = AsyncData(clServer);
      }
    } catch (e) {
      log('monitorServer: $e');
      rethrow;
    }
  }
}

final serverProvider =
    AsyncNotifierProviderFamily<ServerNotifier, CLServer, StoreURL>(
        ServerNotifier.new);
