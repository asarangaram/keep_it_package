import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/servers.dart';

class CloudOnLANSettings extends ConsumerWidget {
  const CloudOnLANSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final myServer = servers.myServer;
    return ListTile(
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Server',
            ),
            if (myServer != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: TextButton(
                  onPressed: () async {
                    ref.read(serversProvider.notifier).myServer = null;
                  },
                  child: CLText.small(
                    'detach',
                    color: CLTheme.of(context).colors.errorTextForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
      subtitle: myServer == null
          ? const Text('You are not connected to any Server')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              // ignore: lines_longer_than_80_chars
                              '${myServer.identifier}@${myServer.name}:${myServer.port} '
                              'is ',
                        ),
                        TextSpan(
                          text: servers.myServerOnline ? 'online' : 'offline',
                          style: TextStyle(
                            color: servers.myServerOnline
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: CLScaleType.small.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CLText.tiny(
                    'Server may be '
                    '${servers.myServerOnline ? 'offline' : 'online'}, '
                    'Check status manually.\n'
                    'Connection keepAlive is not supported in this version',
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
      trailing: myServer == null
          ? ElevatedButton(
              onPressed: () async {
                unawaited(ref.read(serversProvider.notifier).checkConnection);
                await context.push('/servers');
              },
              child: const Text('Connect'),
            )
          : ElevatedButton(
              onPressed: () async {
                await ref.read(serversProvider.notifier).checkConnection;
              },
              child: const Text('Check Connection'),
            ),
    );
  }
}
