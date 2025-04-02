import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server_ui_stub.dart';

class ServerControl extends ConsumerWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ServerControlStub();
  }
}

class ServerSpeedDial extends ConsumerWidget {
  const ServerSpeedDial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ServerSpeedDialStub();
  }
}

class ServerSettings extends ConsumerWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ServerSettingsStub();
  }
}
