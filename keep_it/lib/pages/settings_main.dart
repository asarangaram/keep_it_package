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
  }
}
