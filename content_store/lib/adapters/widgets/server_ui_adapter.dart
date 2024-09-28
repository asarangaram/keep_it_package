import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../online_service/widgets/server_control.dart';
import '../../online_service/widgets/server_settings.dart';
import '../provider/support_online.dart';
import 'server_ui_stub.dart';

class ServerControl extends ConsumerWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(supportOnlineProvider).whenOrNull(
              data: (supportOnline) => supportOnline
                  ? const ServerControlImpl()
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
                  ? const ServerSettingsImpl()
                  : const ServerSettingsStub(),
            ) ??
        const SizedBox.shrink();
  }
}
