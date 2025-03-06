import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'providers/scanner.dart';
import 'providers/server.dart';

class NetworkIcons {
  final noNetwork = MdiIcons.accessPointNetworkOff;
}

final serverIcons = NetworkIcons();

class ScanForServer extends ConsumerStatefulWidget {
  const ScanForServer({super.key});

  @override
  ConsumerState<ScanForServer> createState() => _ScanForServerState();
}

class _ScanForServerState extends ConsumerState<ScanForServer> {
  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(networkScannerProvider);
    final server = ref.watch(serverProvider);

    return Column(
      children: [
        if (!scanner.lanStatus)
          Icon(serverIcons.noNetwork)
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
                              '[${candidate.address}:${candidate.port}]'
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
    );
  }
}
