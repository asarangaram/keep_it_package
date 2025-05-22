import 'package:colan_services/services/app_start_service/views/on_dark_mode.dart';
import 'package:colan_services/services/media_view_service/media_title.dart';
import 'package:colan_services/services/media_view_service/on_more_actions.dart';
import 'package:flutter/material.dart';

class TopBarPageView extends StatelessWidget implements PreferredSizeWidget {
  const TopBarPageView({required this.iconColor, super.key});
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const MediaTitle(),
      actions: [
        OnDarkMode(iconColor: iconColor),
        OnMoreActions(iconColor: iconColor),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
