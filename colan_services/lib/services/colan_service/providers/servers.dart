import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../models/cl_server.dart';
import '../models/cl_server_impl.dart';
import '../models/servers.dart';

extension ServiceExtDiscovery on Discovery {
  Future<void> stop() async => stopDiscovery(this);
}

class ServersNotifier extends StateNotifier<Servers> {
  ServersNotifier({required this.serviceName, required this.checkInterval})
      : super(Servers.unknown()) {
    load();
  }

  final String serviceName;
  final Duration checkInterval;
  Discovery? discovery;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  bool isUpdating = false;

  Future<void> get checkConnection async {
    state = state.clearServers();
    await ((state.myServer != null)
        ? checkServerConnection()
        : searchForServers());
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');

    if (myServerJSON != null) {
      state = state.copyWith(myServer: CLServerImpl.fromJson(myServerJSON));
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      state = state.copyWith(
        lanStatus: result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.ethernet),
      );
      _infoLogger(state.toString());
      if (state.lanStatus) {
        checkConnection;
      }
    });
  }

  Future<void> search() async {
    if (state.lanStatus) {
      await checkConnection;
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    discovery?.removeListener(listener);
    discovery?.stop();
    super.dispose();
  }

  Future<void> checkServerConnection() async {
    if (state.myServer != null) {
      state =
          state.copyWith(myServerOnline: await state.myServer!.hasConnection());
      _infoLogger('checkServerConnection: $state');
    }
  }

  Future<void> listener() async {
    if (isUpdating) return;
    isUpdating = true;
    final servers = <CLServer>{};
    for (final e in discovery?.services ?? <Service>[]) {
      if (e.name != null && e.name!.endsWith('cloudonlapapps')) {
        print('${e.name} ${e.type} ${e.host} ${e.port}');
        final server = CLServerImpl(name: e.host!, port: e.port ?? 5000);
        servers.add(server);
      }
    }
    final availableServers = <CLServer>{};
    for (final server in servers) {
      final availableServer = await server.withId();

      if (availableServer != null) {
        availableServers.add(availableServer);
      }
    }
    state = state.copyWith(servers: availableServers);
    _infoLogger('updateServers: $state');
    isUpdating = false;
  }

  Future<void> searchForServers() async {
    if (discovery != null) {
      discovery!.removeListener(listener);
      await discovery!.stop();
      discovery = null;
    }
    discovery = await startDiscovery(serviceName);

    if (discovery != null) {
      discovery!.addListener(listener);
    }

    return;
  }

  CLServer? get myServer => state.myServer;

  set myServer(CLServer? value) {
    attatch(value);
  }

  Future<void> attatch(CLServer? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString('myServer', (value as CLServerImpl).toJson());
      state = state.copyWith(myServer: value, myServerOnline: true);
    } else {
      await prefs.remove('myServer');
      state = await state.clearMyServer();
    }
  }

  Future<void> get detach async => myServer = null;
}

final serversProvider = StateNotifierProvider<ServersNotifier, Servers>((ref) {
  final notifier = ServersNotifier(
    serviceName: '_http._tcp',
    checkInterval: const Duration(seconds: 5),
  );
  ref.onDispose(notifier.dispose);

  return notifier;
});

const _filePrefix = 'Servers ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
