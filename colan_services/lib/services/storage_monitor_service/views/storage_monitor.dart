import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_info_entry.dart';

class StorageMonitor extends ConsumerWidget {
  const StorageMonitor({required this.appSettings, super.key});
  final AppSettings appSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persistentDirs = CLStandardDirectories.values
        .where((stddir) => stddir.isStore)
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
        ),
        StorageInfoEntry(
          label: 'Cache',
          dirs: cacheDir,
          actions: [
            CLMenuItem(
              title: 'Clear',
              icon: Icons.delete,
              onTap: () async {
                for (final dir in cacheDir) {
                  dir.path.clear();
                }

                return false;
              },
            ),
          ],
        ),
      ],
    );
  }
}
