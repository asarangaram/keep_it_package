import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../online_services/dns_search.dart';

class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);

    return Column(
      children: [
        if (servers.isEmpty) const Text('No Server found'),
        for (final server in servers)
          ListTile(
            title: Text('${server.name}:${server.port}'),
          ),
      ],
    );
  }
}
