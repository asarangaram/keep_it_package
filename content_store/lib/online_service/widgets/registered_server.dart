import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_server.dart';
import '../providers/server.dart';

class RegisterredServerView extends ConsumerWidget {
  const RegisterredServerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetServer(
      errorBuilder: (_, __) {
        return const SizedBox.shrink();
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetServer',
      ),
      builder: (server) {
        if (server.identity == null) return const SizedBox.shrink();
        final map = <String, Widget>{
          'Server': Text(server.identity!.identifier),
          'Location':
              Text('${server.identity!.address}:${server.identity!.port}'),
          'Status': Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${server.isOffline ? 'Offline' : 'Online'} '
                      '\u00A0\u00A0\u00A0\u00A0',
                  style: TextStyle(
                    color: server.isOffline ? Colors.red : Colors.green,
                  ),
                ),
                TextSpan(
                  text: '\u21BA Check Status',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      ref.read(serverProvider.notifier).goOnline();
                    },
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
      },
    );
  }
}
