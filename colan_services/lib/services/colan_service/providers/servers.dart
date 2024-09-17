import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../../../internal/extensions/list.dart';
import '../models/cl_server.dart';
import '../models/servers.dart';

extension ServiceExtDiscovery on Discovery {
  Future<void> stop() async => stopDiscovery(this);
}

class ServersNotifier extends StateNotifier<Servers> {
  ServersNotifier({required this.serviceName}) : super(Servers.unknown()) {
    log('Instance created ');
    _initialize();
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
      name: 'Online Service: Server Finder',
    );
  }

  final String serviceName;

  Discovery? discovery;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  bool isUpdating = false;

  Future<void> get checkConnection async {
    await ((state.myServer != null)
        ? checkServerConnection()
        : searchForServers());
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');

    if (myServerJSON != null) {
      final myServer = CLServer.fromJson(myServerJSON);
      log('Server found from history. $myServer');
      state = state.copyWith(myServer: myServer);
    }

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final updatedLanStatus = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (updatedLanStatus != state.lanStatus) {
        log('Network Connectivity: '
            '${updatedLanStatus ? "available" : 'not available'} ');
        state = state.copyWith(lanStatus: updatedLanStatus);

        if (state.lanStatus) {
          checkConnection;
        } else {
          if (state.myServer != null) {
            state = state.copyWith(myServerOnline: false, servers: {});
          }
        }
      }
    });
    if (subscription != null) {
      log('Network Connectivity: subscribed');
    }
  }

  Future<void> search() async {
    if (state.lanStatus) {
      log('Rescan Request:  ');
      await checkConnection;
    } else {
      // ignore: lines_longer_than_80_chars
      log('Rescan Request:  ignored, as the device not connected to any network');
    }
  }

  @override
  void dispose() {
    if (subscription != null) {
      log('Network Connectivity: unsubscribed');
      subscription!.cancel();
      subscription = null;
    }
    if (discovery != null) {
      discovery!.removeListener(listener);
      log('NSD: unsusbscribed');

      discovery!.stop();
      log('NSD: Start searching for '
          '"Cloud on LAN" services in the local area network');
    }
    super.dispose();
  }

  Future<void> checkServerConnection() async {
    if (state.myServer != null) {
      state =
          state.copyWith(myServerOnline: await state.myServer!.hasConnection());
      log('Server ${state.myServer} is '
          '${state.myServerOnline ? "online" : "offline"}');
    } else {
      log('This function should not be called without a server registered');
    }
  }

  Future<void> listener() async {
    final servers = <CLServer>{};
    for (final e in discovery?.services ?? <Service>[]) {
      if (e.name != null && e.name!.endsWith('cloudonlapapps')) {
        final server = CLServer(name: e.host!, port: e.port ?? 5000);
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

    if (availableServers.isNotEmpty) {
      if (state.servers?.isDifferent(availableServers) ?? true) {
        log('NSD: Found ${availableServers.length} server(s) in the network. ');
        state = state.copyWith(servers: availableServers);
      }
    } else {
      state = state.copyWith(servers: {});
    }
  }

  Future<void> searchForServers() async {
    log('NSD: Start searching for "Cloud on LAN" '
        'services in the local area network');
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
    if (value != null && state.myServer != null) {
      if (state.myServer != value) {
        log("can't register ($value) as "
            'another server( ${state.myServer}) is registered');
      }
      return;
    }
    if (state.myServer != value) {
      if (value != null) {
        await prefs.setString('myServer', value.toJson());
        state = state.copyWith(myServer: value, myServerOnline: true);
        log('server registered $myServer');
        return;
      } else {
        await prefs.remove('myServer');
        state = await state.clearMyServer();
        log('server unregistered ');
        return;
      }
    }
  }
}

final serversProvider = StateNotifierProvider<ServersNotifier, Servers>((ref) {
  final notifier = ServersNotifier(serviceName: '_http._tcp');
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
