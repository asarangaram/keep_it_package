import 'dart:io';

import 'package:colan_services/services/settings_service/models/m1_app_settings.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/extensions.dart';

import '../../storage_service/extensions/ext_directory.dart';
import '../../storage_service/extensions/human_readable.dart';
import '../../store_service/store_service.dart';
import '../providers/backup_stream.dart';

class BackupService extends ConsumerWidget {
  const BackupService({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreManager(
      builder: (theStore) {
        final backupStatus = ref.watch(backupNowProvider(theStore));
        return backupStatus.when(
          loading: () => const ListTile(
            title: Text('Backup'),
            trailing: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => ListTile(
            title: const Text('Backup'),
            trailing: Text('Error while processing backup. $error'),
          ),
          data: (progress) {
            if (progress.isDone) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Backup'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        theStore.appSettings.directories.backup.path.clear();
                        ref.read(backupFileProvider.notifier).state =
                            await theStore.createBackupFile();
                      },
                      child: const Text('Backup Now'),
                    ),
                    subtitle: const Text(
                      'This will remove earlier backup '
                      'and create a new backup.',
                    ),
                  ),
                  AvailableBackup(appSettings: theStore.appSettings),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Backing up ... '),
                ProgressBar(
                  progress: progress.fractCompleted,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AvailableBackup extends ConsumerWidget {
  const AvailableBackup({required this.appSettings, super.key});
  final AppSettings appSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currBackupFile = ref.watch(backupFileProvider);
    final FileSystemEntity? backupFile;
    if (currBackupFile != null) {
      backupFile = File(currBackupFile);
    } else {
      backupFile = appSettings.directories.backup.path.listSync().firstOrNull;
    }

    if (backupFile == null) return const SizedBox.shrink();
    final stats = backupFile.statSync();
    final backupTime = stats.modified.toDisplayFormat();
    final fileSize = '(${stats.size.toHumanReadableFileSize()})';
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Last Backup:',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: TextButton(
                          onPressed: () async {
                            appSettings.directories.backup.path.clear();
                            ref.read(backupFileProvider.notifier).state = null;
                          },
                          child: CLText.small(
                            'Remove',
                            color:
                                CLTheme.of(context).colors.errorTextForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CLText.small(
                  '$backupTime $fileSize',
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final box = context.findRenderObject() as RenderBox?;
              await TheStore.of(context).shareFiles(
                context,
                [backupFile!.path],
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );
            },
            child: const Text('download'),
          ),
        ],
      ),
    );
  }
}
