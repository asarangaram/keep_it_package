import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../models/backup_files.dart';

class BackupView extends StatefulWidget {
  const BackupView({super.key});

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  String? outFile;
  @override
  Widget build(BuildContext context) {
    if (outFile != null) {
      return Container();
    }
    return GetAppSettings(
      builder: (appSettings) {
        final persistentDirs = CLStandardDirectories.values
            .where((stddir) => stddir.isPersistent)
            .map(appSettings.directories.standardDirectory)
            .toList();

        return StreamProgressView(
          stream: () => BackupManager(
            directories: persistentDirs.map((e) => e.path).toList(),
            baseDir: appSettings.directories.persistent,
            backupFolder: appSettings.directories.persistent,
          ).backupStream(
            onDone: (output) => setState(() {
              outFile = output;
            }),
          ),
          onCancel: () {},
        );
      },
    );
  }
}
