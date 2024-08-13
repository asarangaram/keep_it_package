import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multicast_dns/multicast_dns.dart';

import 'cl_server.dart';

class ServersNotifier extends StateNotifier<Set<CLServer>> {
  ServersNotifier({required this.serviceName, required this.checkInterval})
      : super({}) {
    client = MDnsClient();
    search();
  }
  late final MDnsClient client;
  final String serviceName;
  final Duration checkInterval;
  Timer? _timer; // Timer instance to manage periodic checks

  Future<void> search() async {
    await updateServers(await checkServerStatus());

    _timer = Timer.periodic(checkInterval, (Timer timer) async {
      await updateServers(await checkServerStatus());
    });
  }

  Future<void> updateServers(Set<CLServer> detectedServers) async {
    final servers = {...state, ...detectedServers};
    final availableServers = <CLServer>{};
    for (final server in servers) {
      if (await server.hasResonse) {
        availableServers.add(server);
      }
    }
    state = availableServers;
  }

  Future<Set<CLServer>> checkServerStatus() async {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final serversProvider =
    StateNotifierProvider<ServersNotifier, Set<CLServer>>((ref) {
  final notifier = ServersNotifier(
    serviceName: '_image_repo_api._tcp',
    checkInterval: const Duration(seconds: 5),
  );
  ref.onDispose(notifier.dispose);

  return notifier;
});
