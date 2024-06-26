import 'dart:async';
import 'dart:math';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
                    const BackupView(),
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

class BackupView extends ConsumerStatefulWidget {
  const BackupView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackupViewState();
}

class _BackupViewState extends ConsumerState<BackupView> {
  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return const BackupWatch();
      },
    );
  }
}

class BackupWatch extends ConsumerWidget {
  const BackupWatch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupStatus = ref.watch(backupNowProvider);
    return backupStatus.whenOrNull(
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, stackTrace) {
            return Center(child: Text('Error while processing backup. $error'));
          },
          data: (progress) {
            if (progress.isDone) {
              return ListTile(
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
              );
            }
            return Padding(
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
            );
          },
        ) ??
        Container();
  }
}
