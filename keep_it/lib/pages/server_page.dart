import 'package:colan_cmdline/colan_cmdline.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../online_services/providers/servers.dart';

class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);

    return switch (servers) {
      (final Servers servers) when !servers.lanStatus => const NoConnection(),
      (final Servers servers) when servers.myServer == null => NoServer(
          servers: servers,
        ),
      (final Servers servers) when !servers.myServerOnline =>
        OfflineServer(myServer: servers.myServer!),
      _ => OnLineServer(myServer: servers.myServer!)
    };
  }
}

class NoConnection extends ConsumerWidget {
  const NoConnection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}

class NoServer extends ConsumerWidget {
  const NoServer({required this.servers, super.key});
  final Servers servers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(MdiIcons.cloud, size: 40),
          const CLText.standard('Servers'),
          if (servers.isEmpty) const Text('No Server found'),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final server in servers.servers)
                    ListTile(
                      title: CLText.standard(
                        '${server.name}:${server.port}',
                        textAlign: TextAlign.start,
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('Tap to select '),
                      ),
                      trailing: Icon(MdiIcons.lanConnect),
                      onTap: () {
                        ref.read(serversProvider.notifier).myServer = server;
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineServer extends ConsumerWidget {
  const OfflineServer({required this.myServer, super.key});
  final CLServer myServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('$myServer is Offline');
  }
}

class OnLineServer extends ConsumerWidget {
  const OnLineServer({required this.myServer, super.key});
  final CLServer myServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text('$myServer is Online');
  }
}
