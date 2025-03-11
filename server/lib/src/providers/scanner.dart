import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'package:server/server.dart';
import 'package:store_revised/store_revised.dart';

extension ServiceExtDiscovery on Discovery {
  Future<void> stop() async => stopDiscovery(this);
}

class NetworkScannerNotifier extends StateNotifier<NetworkScanner2> {
  NetworkScannerNotifier({required this.serviceName})
      : super(NetworkScanner2.unknown()) {
    log('Instance created ');
    _initialize();
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
      name: 'Online Service: Network Scanner',
    );
  }

  final String serviceName;

  Discovery? discovery;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  bool isUpdating = false;

  Future<void> _initialize() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final updatedLanStatus = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (updatedLanStatus != state.lanStatus) {
        log('Network Connectivity: '
            '${updatedLanStatus ? "available" : 'not available'} ');

        if (updatedLanStatus) {
          state = state.copyWith(lanStatus: updatedLanStatus);
          searchForServers();
        } else {
          state = state.copyWith(lanStatus: updatedLanStatus, servers: {});
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
      await searchForServers();
    } else {
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

  Future<void> listener() async {
    final servers = <CLServer>{};
    for (final e in discovery?.services ?? <Service>[]) {
      if (e.name != null && e.name!.endsWith('cloudonlapapps')) {
        final server = CLServer(address: e.host!, port: e.port ?? 5000);
        final serverWithID = await server.withId();

        servers.add(serverWithID ?? server);
      }
    }

    if (servers.isNotEmpty) {
      if (state.servers?.isDifferent(servers) ?? true) {
        log('NSD: Found ${servers.length} server(s) in the network. ');
        state = state.copyWith(servers: servers);
      }
    } else {
      log('NSD: No server in the network. ');
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
}

final networkScannerProvider =
    StateNotifierProvider<NetworkScannerNotifier, NetworkScanner2>((ref) {
  final notifier = NetworkScannerNotifier(serviceName: '_http._tcp');
  ref.onDispose(notifier.dispose);

  return notifier;
});
