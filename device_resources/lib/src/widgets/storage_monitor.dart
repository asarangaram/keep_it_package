import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_directory.dart';
import '../models/file_system/models/cl_directories.dart';
import 'storage_info_entry.dart';
import 'w1_get_app_settings.dart';

class StorageMonitor extends ConsumerWidget {
  const StorageMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetAppSettings(
      loadingBuilder: () => const SizedBox.shrink(),
      errorBuilder: (object, st) {
        return const SizedBox.shrink();
      },
      builder: (appSettings) {
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
              action: ElevatedButton.icon(
                onPressed: () async {
                  for (final dir in cacheDir) {
                    dir.path.clear();
                  }
                },
                label: const Text('Clear'),
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        );
      },
    );
  }
}
