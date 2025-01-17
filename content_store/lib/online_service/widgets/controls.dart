import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_server.dart';
import '../providers/server.dart';
import 'labeled_icon_horiz.dart';

class WorkOffline extends ConsumerWidget {
  const WorkOffline({this.onTap, super.key});
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

class GoOnline extends ConsumerWidget {
  const GoOnline({this.onTap, super.key});
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

class DisconnectServer extends ConsumerWidget {
  const DisconnectServer({this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLButtonIconLabelled.small(
      clIcons.syncIcons.disconnectIconData,
      'Disconnect',
      onTap: onTap,
    );
  }
}

class ConnectServer extends ConsumerWidget {
  const ConnectServer({this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLButtonIconLabelled.small(
      clIcons.syncIcons.connectIconData,
      'Connect',
      onTap: onTap,
    );
  }
}

class DeregisterServer extends ConsumerWidget {
  const DeregisterServer({this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLButtonIconLabelled.small(
      clIcons.syncIcons.detachIconData,
      'DeRegister',
      onTap: onTap,
      color: Theme.of(context).colorScheme.error,
    );
  }
}

class SyncServer extends ConsumerWidget {
  const SyncServer({this.onTap, super.key});
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

class SyncServer1 extends ConsumerWidget {
  const SyncServer1({this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLButtonIconLabelled.small(
      clIcons.syncIcons.syncIconData,
      'Sync Now',
      onTap: onTap,
    );
  }
}

class OpenCollectionsStoragePreferences extends ConsumerWidget {
  const OpenCollectionsStoragePreferences({this.onTap, super.key});
  final Future<bool?> Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLButtonIconLabelled.small(
      clIcons.collectionsSelect,
      'Collections',
      onTap: onTap,
    );
  }
}

class OfflinePreference extends ConsumerWidget {
  const OfflinePreference({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetServer(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
        // ignore: dead_code
      },
      loadingBuilder: () {
        throw UnimplementedError('loadingBuilder');
        // ignore: dead_code
      },
      builder: (server) {
        if (server.isOffline) {
          return const SizedBox.shrink();
        }
        if (server.workingOffline) {
          return ConnectServer(
            onTap: () async {
              ref.read(serverProvider.notifier).goOnline();
              return true;
            },
          );
        }
        return DisconnectServer(
          onTap: () async {
            ref.read(serverProvider.notifier).workOffline();
            return true;
          },
        );
      },
    );
  }
}
