import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../store_service/providers/store.dart';
import '../providers/network_scanner.dart';
import '../providers/online_status.dart';
import '../providers/registerred_server.dart';
import '../providers/working_offline.dart';
import 'controls.dart';
import 'registered_server.dart';

class CloudOnLANSettings extends ConsumerWidget {
  const CloudOnLANSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    final registeredServer = ref.watch(registeredServerProvider);
    final isOnline = ref.watch(serverOnlineStatusProvider);
    final workingOffline = ref.watch(workingOfflineProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: const Text('Server Settings'),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        subtitle:
            registeredServer == null ? null : const RegisterredServerView(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const OfflinePreference(),
                if (isOnline && !workingOffline)
                  SyncServer(
                    onTap: ref.read(storeProvider.notifier).syncServer,
                  )
                else
                  Container(),
                if (registeredServer != null)
                  DeregisterServer(
                    onTap:
                        ref.read(registeredServerProvider.notifier).deregister,
                  )
                else
                  Container(),
              ]
                  .map(
                    (e) => Expanded(
                      child: Center(child: e),
                    ),
                  )
                  .toList(),
            ),
          ),
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
