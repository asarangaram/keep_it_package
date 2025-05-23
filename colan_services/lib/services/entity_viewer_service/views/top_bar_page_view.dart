import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/app_start_service/views/on_dark_mode.dart';
import 'package:colan_services/services/entity_viewer_service/widgets/media_title.dart';
import 'package:colan_services/services/entity_viewer_service/widgets/on_more_actions.dart';
import 'package:flutter/material.dart';

class TopBarPageView extends StatelessWidget implements PreferredSizeWidget {
  const TopBarPageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GetCurrentEntity(
        builder: (entity) {
          return MediaTitle(entity: entity);
        },
      ),
      actions: const [
        OnDarkMode(),
        OnMoreActions(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
