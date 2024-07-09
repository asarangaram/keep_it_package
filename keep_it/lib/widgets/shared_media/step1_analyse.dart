import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return GetDBManager(
          builder: (dbManager) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: WizardLayout(
                title: 'Analysing Shared Media',
                onCancel: onCancel,
                child: StreamProgressView(
                  stream: () => CLMediaProcess.analyseMedia(
                    dbManager: dbManager,
                    media: incomingMedia,
                    findItemByMD5: dbManager.getMediaByMD5,
                    onDone: onDone,
                    appSettings: appSettings,
                  ),
                  onCancel: onCancel,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
