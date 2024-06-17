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
            final dirInfoList = [
              DirInfo(
                name: 'Document Directory',
                directory: appSettings.directories.docDir.path.replaceFirst(
                  '${appSettings.directories.container.path}/',
                  '',
                ),
                statsAsync: ref.watch(
                  storageStatisticsProvider(appSettings.directories.docDir),
                ),
              ),
              DirInfo(
                name: 'Cache Directory',
                directory: appSettings.directories.cacheDir.path.replaceFirst(
                  '${appSettings.directories.container.path}/',
                  '',
                ),
                statsAsync: ref.watch(
                  storageStatisticsProvider(appSettings.directories.cacheDir),
                ),
              ),
              DirInfo(
                name: 'Download Directory',
                directory: appSettings.downloadDir.path.replaceFirst(
                  '${appSettings.directories.container.path}/',
                  '',
                ),
                statsAsync: ref.watch(
                  storageStatisticsProvider(appSettings.downloadDir),
                ),
              ),
              DirInfo(
                name: 'System Temp (For Developers)',
                directory: appSettings.directories.systemTemp.path.replaceFirst(
                  '${appSettings.directories.container.path}/',
                  '',
                ),
                statsAsync: ref.watch(
                  storageStatisticsProvider(
                    appSettings.directories.systemTemp,
                  ),
                ),
              ),
            ];

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
                    for (final dirInfo in dirInfoList)
                      dirInfo.statsAsync.whenOrNull(
                            data: (stat) {
                              return ListTile(
                                title: Text(
                                  '${dirInfo.name} [${dirInfo.directory}]',
                                ),
                                subtitle: Text(stat.statistics),
                                trailing: const Icon(Icons.archive),
                              );
                            },
                          ) ??
                          const SizedBox.shrink(),
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
