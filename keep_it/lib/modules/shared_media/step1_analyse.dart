import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'cl_media_process.dart';
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
      builder: (resources) {
        return GetDBManager(
          builder: (dbManager) {
            return SharedMediaWizard.buildWizard(
              context, ref,
              title: 'Analysing Shared Media',
              message: 'Please wait while analysing media files',
              //option1: CLMenuItem(title: 'Yes', icon: Icons.abc),
              //option2: CLMenuItem(title: 'No', icon: Icons.abc),
              child: StreamProgressView(
                stream: () => CLMediaProcess.analyseMedia(
                  media: incomingMedia,
                  findItemByMD5: (md5String) async =>
                      (DBQueries.mediaByMD5.sql as DBQuery<CLMedia>)
                          .copyWith(parameters: [md5String]).read(dbManager.db),
                  onDone: onDone,
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