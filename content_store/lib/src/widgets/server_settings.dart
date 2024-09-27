import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_nw_scanner.dart';
import '../builders/get_server.dart';
import '../providers/server.dart';
import 'controls.dart';
import 'registered_server.dart';

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetNetworkScanner(
      builder: (scanner) {
        return GetServer(
          builder: (server) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpansionTile(
                title: const Text('Server Settings'),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.zero,
                subtitle:
                    server.isRegistered ? null : const RegisterredServerView(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const OfflinePreference(),
                        if (server.canSync)
                          SyncServer1(
                            onTap: () async {
                              ref.read(serverProvider.notifier).sync();
                              return true;
                            },
                          )
                        else
                          Container(),
                        if (server.isRegistered)
                          DeregisterServer(
                            onTap: () async {
                              // Confirm before deregisterring
                              ref.read(serverProvider.notifier).sync();
                              return true;
                            },
                          )
                        else
                          Container(),
                      ]
                          .map(
                            (e) => Expanded(
                              child: Center(
                                child: FractionallySizedBox(
                                  widthFactor: 0.8,
                                  child: e,
                                ),
                              ),
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
                                text:
                                    'No Server found \u00A0\u00A0\u00A0\u00A0',
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
                                    scanner.search();
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
                                text: 'Available Servers '
                                    '\u00A0\u00A0\u00A0\u00A0',
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
                                  ..onTap = scanner.search,
                              ),
                            ],
                          ),
                        ),
                      ),

                      //CLIconLabelled.large(clIcons.serversList, 'Servers'),
                      for (final candidate in scanner.servers!)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${candidate.identifier} '
                                        '[${candidate.name}:${candidate.port}]'
                                        ' \u00A0\u00A0\u00A0\u00A0',
                                  ),
                                  if (candidate != server.identity)
                                    TextSpan(
                                      text: '\u2295Register',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          ref
                                              .read(serverProvider.notifier)
                                              .register(candidate);
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
          },
        );
      },
    );
  }
}
