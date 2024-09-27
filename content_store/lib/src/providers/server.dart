import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import '../models/server.dart';

class ServerNotifier extends StateNotifier<Server> {
  ServerNotifier() : super(const Server()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Read Workoffline from sharedPReference and update
  }

  Future<void> setState(Server server) async {}

  void register(CLServer candidate) =>
      setState(state.copyWith(identity: () => candidate));

  void deregister() => setState(state.copyWith(identity: () => null));

  void goOnline() => setState(state.copyWith(workingOffline: false));

  void workOffline() => setState(state.copyWith(workingOffline: true));

  void sync() {
    if (state.canSync && !state.isSyncing) {
      setState(state.copyWith(isSyncing: true)).then(
        (_) => _sync().then((_) => setState(state.copyWith(isSyncing: false))),
      );
    }
  }

  void checkStatus() {
    return;
  }

  Future<void> _sync() async {
    // await state.sync();
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, Server>((ref) {
  return ServerNotifier();
});
