import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      title: 'Settings',
      pageBuilder: (context, quickMenuScopeKey) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GetDeletedMedia(
              buildOnData: (media) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CLButtonIconLabelled.large(
                      MdiIcons.delete,
                      'Deleted Items (${media.length})',
                      onTap: media.isEmpty
                          ? null
                          : () async {
                              unawaited(context.push('/deleted_media'));
                            },
                      color: Colors.blue,
                      disabledColor: Theme.of(context).disabledColor,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
