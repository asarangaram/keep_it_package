import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/backup_stream.dart';

class BackupService extends ConsumerWidget {
  const BackupService({
    required this.onShareFiles,
    required this.onCreateBackupFile,
    super.key,
  });
  final Future<void> Function(
    BuildContext context,
    List<String> files, {
    Rect? sharePositionOrigin,
  }) onShareFiles;
  final Future<String> Function() onCreateBackupFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupStatus = ref.watch(backupNowProvider);
    return backupStatus.when(
      loading: () => const ListTile(title: CircularProgressIndicator()),
      error: (error, stackTrace) => ListTile(
        title: Text('Error while processing backup. $error'),
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
                        await onCreateBackupFile();
                  },
                  child: const Text('Backup Now'),
                ),
                subtitle: const Text(
                  'This will remove earlier backup '
                  'and create a new backup.',
                ),
              ),
              AvailableBackup(
                onShareFiles: onShareFiles,
              ),
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
  }
}

class AvailableBackup extends StatefulWidget {
  const AvailableBackup({required this.onShareFiles, super.key});
  final Future<void> Function(
    BuildContext context,
    List<String> files, {
    Rect? sharePositionOrigin,
  }) onShareFiles;

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
                  await widget.onShareFiles(
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
