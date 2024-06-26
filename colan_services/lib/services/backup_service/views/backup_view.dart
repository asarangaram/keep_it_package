import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

import '../models/backup_files.dart';

class BackupView extends ConsumerWidget {
  const BackupView({required this.appSettings, super.key});
  final AppSettings appSettings;

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
                    ref.read(refreshProvider.notifier).state++;
                  },
                  child: const Text('Backup Now'),
                ),
                subtitle: const Text(
                  'This will remove earlier backup '
                  'and create a new backup.',
                ),
              ),
              AvailableBackup(
                appSettings: appSettings,
              ),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Backing up ... '),
            Padding(
              padding: const EdgeInsets.all(15),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 50,
                animation: true,
                lineHeight: 20,
                animationDuration: 2000,
                percent: progress.fractCompleted,
                animateFromLastPercent: true,
                center: Text(progress.percentageAsText),
                barRadius: const Radius.elliptical(5, 15),
                progressColor: Theme.of(context).colorScheme.primary,
                maskFilter: const MaskFilter.blur(BlurStyle.solid, 3),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AvailableBackup extends StatefulWidget {
  const AvailableBackup({required this.appSettings, super.key});
  final AppSettings appSettings;

  @override
  State<AvailableBackup> createState() => _AvailableBackupState();
}

class _AvailableBackupState extends State<AvailableBackup> {
  @override
  Widget build(BuildContext context) {
    final backupFile =
        widget.appSettings.directories.backup.path.listSync().firstOrNull;
    if (backupFile == null) {
      return const SizedBox.shrink();
    }
    final stats = backupFile.statSync();
    final backupTime =
        DateFormat('MMM dd, yyyy HH:mm:ss').format(stats.modified);
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
                          onPressed: () {
                            backupFile.deleteSync();
                            setState(() {});
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
              final files = [XFile(backupFile.path)];
              await Share.shareXFiles(
                files,
                subject: 'Backup from KeepIt',
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );
            },
            child: const Text('download'),
          ),
        ],
      ),
    );
    /* if(stats)
    return switch (infoListAsync?.count) {
      null => const SizedBox.shrink(),
      0 => const SizedBox.shrink(),
      1 => ListTile(
          title: Text('Last Backup on }'),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CLButtonIcon.standard(
                MdiIcons.delete,
                color: CLTheme.of(context).colors.errorTextForeground,
              ),
              ElevatedButton(onPressed: () {}, child: const Text('Delete')),
              ElevatedButton(onPressed: () {}, child: const Text('download')),
            ],
          ),
        ),
      _ => const ListTile(title: Text('Too many Backup Found. Unexpected')),
    }; */
  }
}
