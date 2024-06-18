import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

@immutable
class DirInfo {
  const DirInfo({
    required this.name,
    required this.directory,
    required this.statsAsync,
    this.onTapAction,
  });
  final String name;
  final String directory;
  final VoidCallback? onTapAction;
  final AsyncValue<StorageStatistics> statsAsync;
}

class SettingsMainPage extends ConsumerWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      title: 'Settings',
      pageBuilder: (context, quickMenuScopeKey) {
        return GetAppSettings(
          builder: (appSettings) {
            return GetDeletedMedia(
              buildOnData: (deletedMedia) {
                return ListView(
                  children: [
                    if (deletedMedia.isNotEmpty)
                      ListTile(
                        leading: Icon(MdiIcons.delete),
                        trailing: IconButton(
                          icon: Icon(MdiIcons.arrowRight),
                          onPressed: () async {
                            unawaited(context.push('/deleted_media'));
                          },
                        ),
                        title: Text('Deleted Items (${deletedMedia.length})'),
                      ),
                    const StorageInfo(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class StorageInfo extends ConsumerWidget {
  const StorageInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetAppSettings(
      builder: (appSettings) {
        final persistentDirs = CLStandardDirectories.values
            .where((stddir) => stddir.isPersistent)
            .map(appSettings.directories.standardDirectory)
            .toList();
        final cacheDir = CLStandardDirectories.values
            .where((stddir) => !stddir.isPersistent)
            .map(appSettings.directories.standardDirectory)
            .toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StorageInfoEntry(
              label: 'Storage Used',
              dirs: persistentDirs,
              actions: [
                CLMenuItem(
                  title: 'Archive',
                  icon: Icons.archive,
                  onTap: () async {
                    return false;
                  },
                ),
              ],
            ),
            StorageInfoEntry(
              label: 'Cache',
              dirs: cacheDir,
              actions: const [CLMenuItem(title: 'Clear', icon: Icons.delete)],
            ),
          ],
        );
      },
    );
  }
}

class StorageInfoEntry extends ConsumerWidget {
  const StorageInfoEntry({
    required this.label,
    required this.dirs,
    super.key,
    this.actions,
  });
  final String label;
  final List<CLDirectory> dirs;
  final List<CLMenuItem>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoListAsync = dirs
        .map(
          (dir) => ref.watch(dir.infoStream).whenOrNull(data: (data) => data),
        )
        .toList();
    CLDirectoryInfo? info;
    Widget? trailing;
    final infoReady = infoListAsync.every((element) => element != null);
    if (infoReady) {
      info = infoListAsync.reduce((a, b) => a! + b!);
      trailing = (actions?.isEmpty ?? true)
          ? null
          : ElevatedButton.icon(
              onPressed: actions![0].onTap,
              label: Text(actions![0].title),
              icon: Icon(actions![0].icon),
            );
    }
    return ListTile(
      title: Text(label),
      subtitle: Text(info?.statistics ?? ''),
      trailing: trailing,
    );
  }
}
