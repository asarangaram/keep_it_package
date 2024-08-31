import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/storage_service/extensions/human_readable.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/extensions.dart';

import 'providers/backup_stream.dart';

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
                  const AvailableBackup(),
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

class AvailableBackup extends StatefulWidget {
  const AvailableBackup({super.key});

  @override
  State<AvailableBackup> createState() => _AvailableBackupState();
}

class _AvailableBackupState extends State<AvailableBackup> {
  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      errorBuilder: (object, st) => const SizedBox.shrink(),
      loadingBuilder: SizedBox.shrink,
      builder: (appSettings) {
        final backupFile =
            appSettings.directories.backup.path.listSync().firstOrNull;
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
                                await backupFile.delete();
                                setState(() {});
                              },
                              child: CLText.small(
                                'Remove',
                                color: CLTheme.of(context)
                                    .colors
                                    .errorTextForeground,
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
                    [backupFile.path],
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  );
                },
                child: const Text('download'),
              ),
            ],
          ),
        );
      },
    );
  }
}
