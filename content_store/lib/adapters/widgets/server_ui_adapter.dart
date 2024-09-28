import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/support_online.dart';
import 'server_ui_stub.dart';

class ServerControl extends ConsumerWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(supportOnlineProvider).whenOrNull(
              data: (supportOnline) => supportOnline
                  ? const Placeholder()
                  : const ServerControlStub(),
            ) ??
        const SizedBox.shrink();
  }
}

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(supportOnlineProvider).whenOrNull(
              data: (supportOnline) => supportOnline
                  ? const Placeholder()
                  : const ServerSettingsStub(),
            ) ??
        const SizedBox.shrink();
  }
}
