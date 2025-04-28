import 'package:flutter/material.dart';

import '../notifier/ui_state.dart';
import 'media_title.dart';
import 'on_close_button.dart';
import 'on_dark_mode.dart';
import 'on_more_actions.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({required this.iconColor, super.key});
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final showMenu = uiStateManager.notifier.select((state) => state.showMenu);
    return ListenableBuilder(
      listenable: showMenu,
      builder: (_, child) {
        return Visibility(visible: showMenu.value, child: child!);
      },
      child: AppBar(
        leading: OnCloseButton(iconColor: iconColor),
        title: const MediaTitle(),
        // centerTitle: true,
        actions: [
          OnDarkMode(iconColor: iconColor),
          OnMoreActions(iconColor: iconColor),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
