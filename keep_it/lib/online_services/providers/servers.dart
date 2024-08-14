import 'dart:async';

import 'package:colan_cmdline/colan_cmdline.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/app_logger.dart';

class ServersNotifier extends StateNotifier<Servers> {
  ServersNotifier({required this.serviceName, required this.checkInterval})
      : super(Servers.unknown()) {
    client = MDnsClient();
    search();
  }
  late final MDnsClient client;
  final String serviceName;
  final Duration checkInterval;
  StreamSubscription<List<ConnectivityResult>>? subscription;
  Timer? _timer; // Timer instance to manage periodic checks

  Future<void> get checkConnection async =>
      ((state.myServer != null) ? keepConnectionActive() : updateServers());

  Future<void> search() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');

    if (myServerJSON != null) {
      state = state.copyWith(myServer: CLServer.fromJson(myServerJSON));
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      state =
          state.copyWith(lanStatus: result.contains(ConnectivityResult.wifi));
      _infoLogger(state.toString());
      if (state.lanStatus) {
        checkConnection.then((_) {
          _infoLogger('timer started: keepConnectionActive');
          _timer = Timer.periodic(checkInterval, (Timer timer) async {
            await checkConnection;
          });
        });
      } else {
        _timer?.cancel();
        _infoLogger('timer cancelled');
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> keepConnectionActive() async {
    if (state.myServer != null) {
      state =
          state.copyWith(myServerOnline: await state.myServer!.hasConnection);
      _infoLogger('keepConnectionActive: $state');
    }
  }

  Future<void> updateServers() async {
    final detectedServers = await searchForServers();
    final servers = {...detectedServers};
    final availableServers = <CLServer>{};
    for (final server in servers) {
      final availableServer = await server.withId;

      if (availableServer?.hasID ?? false) {
        availableServers.add(availableServer!);
      }
    }
    state = state.copyWith(servers: availableServers);
    _infoLogger('updateServers: $state');
  }

  Future<Set<CLServer>> searchForServers() async {
    final servers = <CLServer>{};
    await client.start();

    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(serviceName),
    )) {
      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        final server = CLServer(name: srv.target, port: srv.port);
        servers.add(server);
      }
    }
    client.stop();
    return servers;
  }

  CLServer? get myServer => state.myServer;

  set myServer(CLServer? value) {
    myServerAsync(value);
  }

  Future<void> myServerAsync(CLServer? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString('myServer', value.toJson());
      state = state.copyWith(myServer: value, myServerOnline: true);
    } else {
      await prefs.remove('myServer');
      state = await state.clearMyServer();
    }
  }
}

final serversProvider = StateNotifierProvider<ServersNotifier, Servers>((ref) {
  final notifier = ServersNotifier(
    serviceName: '_image_repo_api._tcp',
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
