import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_directory.dart';

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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StorageInfoEntry(
              label: 'Storage Used',
              dirs: appSettings.dir.persistentDirs,
            ),
            StorageInfoEntry(
              label: 'Cache',
              dirs: appSettings.dir.cacheDirs,
              action: ElevatedButton.icon(
                onPressed: () async {
                  for (final dir in appSettings.dir.cacheDirs) {
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
