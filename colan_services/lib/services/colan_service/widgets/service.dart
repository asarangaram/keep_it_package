import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/cl_server.dart';
import '../models/servers.dart';
import '../providers/servers.dart';

class CloudOnLanService extends ConsumerWidget {
  const CloudOnLanService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);

    return Column(
      children: [
        CLIconLabelled.large(clIcons.serversList, 'Servers'),
        Expanded(
          child: switch (servers) {
            (final Servers s) when !s.lanStatus => const NoConnection(),
            (final Servers s) when s.servers == null => const CLLoadingView(
                message: 'Searching',
              ),
            (final Servers s) when s.isEmpty => const NoServer(),
            (final Servers servers) when servers.myServer == null =>
              ServerSelection(
                servers: servers.servers,
              ),
            (final Servers servers) when !servers.myServerOnline =>
              OfflineServer(myServer: servers.myServer!),
            _ => OnLineServer(myServer: servers.myServer!)
          },
        ),
        const ServerPageNavigationControls(),
      ],
    );
  }
}

class NoConnection extends ConsumerWidget {
  const NoConnection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CLIconLabelled.large(
              clIcons.noNetwork,
              'No Network',
            ),
          ),
          const ServerPageNavigationControls(),
        ],
      ),
    );
  }
}

class NoServer extends ConsumerWidget {
  const NoServer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: CLText.large('No Server found'));
  }
}

class ServerSelection extends ConsumerWidget {
  const ServerSelection({required this.servers, super.key});
  final Set<CLServer>? servers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final server in servers!)
                    ListTile(
                      title: CLText.standard(
                        server.identifier,
                        textAlign: TextAlign.start,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('@ ${server.name}:${server.port}'),
                      ),
                      trailing: FittedBox(
                        child: CLIconLabelled.large(
                          clIcons.connectToServer,
                          'Connect',
                        ),
                      ),
                      onTap: () {
                        // TODO(anandas): : Confirmation dialog
                        ref.read(serversProvider.notifier).myServer = server;
                        context.pop();
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

class ServerPageNavigationControls extends ConsumerWidget {
  const ServerPageNavigationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (CLPopScreen.canPop(context))
            CLPopScreen.onTap(
              child: CLButtonIcon.large(
                clIcons.pagePop,
              ),
            )
          else
            Container(),
          Container(),
          if (servers.lanStatus)
            CLButtonIcon.large(
              clIcons.searchForServers,
              onTap: () {
                ref.read(serversProvider.notifier).search();
              },
            ),
        ].map((e) => Expanded(child: Center(child: e))).toList(),
      ),
    );
  }
}
