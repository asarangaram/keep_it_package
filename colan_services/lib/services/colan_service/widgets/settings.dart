import 'dart:developer';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/network_scanner.dart';
import '../providers/online_status.dart';
import '../providers/registerred_server.dart';

class CloudOnLANSettings extends ConsumerWidget {
  const CloudOnLANSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final registeredServer = ref.watch(registeredServerProvider);
    log('Registerred Server is $registeredServer', name: 'CloudOnLANSettings');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: const Text('Server Settings'),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        subtitle: registeredServer == null ? null : const ServerStatus(),
        children: [
          /* Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SpeedDialIcon(
                  clIcons.syncIcons.syncOptionsIconData,
                  'Sync Settings',
                ),
                SpeedDialIcon(
                  clIcons.syncIcons.disconnectIconData,
                  'Disconnect',
                ),
                SpeedDialIcon(
                  clIcons.syncIcons.connectIconData,
                  'Connect',
                ),
                SpeedDialIcon(
                  clIcons.syncIcons.detachIconData,
                  'Deregister',
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroudColor: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ), */
          if (!scanner.lanStatus)
            CLIconLabelled.large(clIcons.noNetwork, 'No Network')
          else if (scanner.servers == null)
            const CircularProgressIndicator.adaptive()
          else ...[
            if (scanner.servers!.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'No Server found \u00A0\u00A0\u00A0\u00A0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '\u21BA Refresh',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: CLScaleType.small.fontSize,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ref.read(networkScannerProvider.notifier).search();
                          },
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Available Servers \u00A0\u00A0\u00A0\u00A0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '\u21BA Refresh',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: CLScaleType.small.fontSize,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ref.read(networkScannerProvider.notifier).search();
                          },
                      ),
                    ],
                  ),
                ),
              ),

              //CLIconLabelled.large(clIcons.serversList, 'Servers'),
              for (final server in scanner.servers!)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${server.identifier} '
                                '[${server.name}:${server.port}]'
                                ' \u00A0\u00A0\u00A0\u00A0',
                          ),
                          if (server != registeredServer)
                            TextSpan(
                              text: '\u2295Register',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ref
                                      .read(registeredServerProvider.notifier)
                                      .register(server);
                                },
                            )
                          else
                            TextSpan(
                              text: 'Registered',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: CLScaleType.small.fontSize,
                              ),
                            ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class ServerStatus extends ConsumerWidget {
  const ServerStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(registeredServerProvider);

    final isOnline = ref.watch(serverOnlineStatusProvider);
    if (server == null) return const SizedBox.shrink();

    final map = <String, Widget>{
      'Server': Text(server.identifier),
      'Location': Text('${server.name}:${server.port}'),
      'Status': Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  '${isOnline ? 'Online' : 'Offline'} \u00A0\u00A0\u00A0\u00A0',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.red,
              ),
            ),
            TextSpan(
              text: '\u21BA Check Status',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap =
                    ref.read(serverOnlineStatusProvider.notifier).checkStatus,
            ),
          ],
        ),
      ),
    };

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(seconds: 1),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...map.keys.map(
                  (e) => Text(
                    '$e : ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: map.values.toList(),
            ),
          ],
        ),
      ),
    );
  }
}
