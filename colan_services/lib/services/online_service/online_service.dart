import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/servers.dart';

class CloudOnLANService extends ConsumerWidget {
  const CloudOnLANService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final serv = servers.myServer;
    return ListTile(
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Server',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: TextButton(
                onPressed: () async {
                  await ref.read(serversProvider.notifier).detach;
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
      subtitle: serv == null
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
                              '${serv.identifier}@${serv.name}:${serv.port} is ',
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
      trailing: serv == null
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
