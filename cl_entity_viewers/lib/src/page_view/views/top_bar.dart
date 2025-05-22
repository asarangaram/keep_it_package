import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'media_title.dart';

import 'on_more_actions.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({required this.iconColor, super.key});
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // FIXME leading: OnCloseButton(iconColor: iconColor),
      title: const MediaTitle(),
      // centerTitle: true,
      actions: [
        // FIXME OnDarkMode(iconColor: iconColor),
        OnMoreActions(iconColor: iconColor),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
