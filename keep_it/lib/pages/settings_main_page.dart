import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SettingsMainPage extends ConsumerWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      title: 'Settings',
      backButton: null,
      pageBuilder: (context, quickMenuScopeKey) {
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
                        await TheScreenHandler.of(context).openWizard(
                          context,
                          deletedMedia,
                          UniversalMediaSource.deleted,
                        );
                      },
                    ),
                    title: Text('Deleted Items (${deletedMedia.length})'),
                  ),
                const StorageMonitor(),
                BackupService(
                  onShareFiles: TheScreenHandler.of(context).shareFiles,
                  onCreateBackupFile:
                      TheScreenHandler.of(context).createBackupFile,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
