import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store/store.dart';

import '../widgets/act_on_long_press.dart';

class SettingsMain extends StatelessWidget {
  const SettingsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      title: 'Settings',
      pageBuilder: (context, quickMenuScopeKey) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: GetDBManager(
                  builder: (dbManager) {
                    return ActOnLongPress(
                      action: () async {
                        await dbManager.resetStore();
                        for (final dir in [
                          await getApplicationDocumentsDirectory(),
                          await getApplicationCacheDirectory(),
                        ]) {
                          dir.clear();
                        }
                        await Future<void>.delayed(const Duration(seconds: 5));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
