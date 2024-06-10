import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'wizard_page.dart';

class AnalysePage extends SharedMediaWizard {
  const AnalysePage({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetAppSettings(
      builder: (appSettings) {
        return GetDBManager(
          builder: (dbManager) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: SharedMediaWizard.buildWizard(
                context, ref,
                title: 'Analysing Shared Media',
                message: 'Please wait while we analysing media files',
                //option1: CLMenuItem(title: 'Yes', icon: Icons.abc),
                //option2: CLMenuItem(title: 'No', icon: Icons.abc),
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
                onCancel: onCancel,
              ),
            );
          },
        );
      },
    );
  }
}
