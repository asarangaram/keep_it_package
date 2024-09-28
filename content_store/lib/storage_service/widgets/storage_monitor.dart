import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_directory.dart';
import 'get_device_directories.dart';
import 'storage_info_entry.dart';

class StorageMonitor extends ConsumerWidget {
  const StorageMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDeviceDirectories(
      loadingBuilder: () => const SizedBox.shrink(),
      errorBuilder: (object, st) {
        return const SizedBox.shrink();
      },
      builder: (deviceDirectories) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StorageInfoEntry(
              label: 'Storage Used',
              dirs: deviceDirectories.persistentDirs,
            ),
            StorageInfoEntry(
              label: 'Cache',
              dirs: deviceDirectories.cacheDirs,
              action: ElevatedButton.icon(
                onPressed: () async {
                  for (final dir in deviceDirectories.cacheDirs) {
                    dir.path.clear();
                  }
                },
                label: const Text('Clear'),
                icon: Icon(clIcons.deleteItem),
              ),
            ),
          ],
        );
      },
    );
  }
}
