import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/online_status.dart';
import '../providers/working_offline.dart';
import 'labeled_icon_horiz.dart';

class WorkOffline extends ConsumerWidget {
  const WorkOffline({required this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabeledIconHorizontal(
      CLMenuItem(
        icon: clIcons.syncIcons.disconnectIconData,
        title: 'Work Offline',
        onTap: onTap,
      ),
    );
  }
}

class DisconnectServer extends ConsumerWidget {
  const DisconnectServer({required this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabeledIconHorizontal(
      CLMenuItem(
        icon: clIcons.syncIcons.disconnectIconData,
        title: 'Disconnect',
        onTap: onTap,
      ),
    );
  }
}

class ConnectServer extends ConsumerWidget {
  const ConnectServer({required this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabeledIconHorizontal(
      CLMenuItem(
        icon: clIcons.syncIcons.connectIconData,
        title: 'Go Online',
        onTap: onTap,
      ),
    );
  }
}

class DeregisterServer extends ConsumerWidget {
  const DeregisterServer({required this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabeledIconHorizontal.dangerous(
      CLMenuItem(
        icon: clIcons.syncIcons.detachIconData,
        title: 'DeRegister',
        onTap: onTap,
      ),
    );
  }
}

class SyncServer extends ConsumerWidget {
  const SyncServer({required this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabeledIconHorizontal(
      CLMenuItem(
        icon: clIcons.syncIcons.syncIconData,
        title: 'Sync Now',
        onTap: onTap,
      ),
    );
  }
}

class OfflinePreference extends ConsumerWidget {
  const OfflinePreference({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingOffline = ref.watch(workingOfflineProvider);
    final isOnline = ref.watch(serverOnlineStatusProvider);
    print('workingOffline : $workingOffline');
    if (!isOnline) {
      return const SizedBox.shrink();
    }
    if (workingOffline) {
      return ConnectServer(
        onTap: () async {
          ref.read(workingOfflineProvider.notifier).state = false;
          return true;
        },
      );
    }
    return DisconnectServer(
      onTap: () async {
        ref.read(workingOfflineProvider.notifier).state = true;
        return true;
      },
    );
  }
}
