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
