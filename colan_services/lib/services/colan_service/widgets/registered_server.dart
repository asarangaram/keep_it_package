import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/online_status.dart';
import '../providers/registerred_server.dart';

class RegisterredServerView extends ConsumerWidget {
  const RegisterredServerView({super.key});

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