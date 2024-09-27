import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_server.dart';
import 'registerred_server.dart';

class ServerOnlineStatusNotifier extends StateNotifier<bool> {
  ServerOnlineStatusNotifier(this.server) : super(false) {
    _initialize();
  }
  final CLServer? server;
  Timer? timer;
  Future<void> _initialize() async {
    state = (await server?.hasConnection()) ?? false;
    timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      server?.hasConnection().then((val) {
        state = val;
      });
    });
  }

  void checkStatus() {
    server?.hasConnection().then((val) {
      state = val;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

final serverOnlineStatusProvider =
    StateNotifierProvider<ServerOnlineStatusNotifier, bool>((ref) {
  final server = ref.watch(registeredServerProvider);
  return ServerOnlineStatusNotifier(server);
});
