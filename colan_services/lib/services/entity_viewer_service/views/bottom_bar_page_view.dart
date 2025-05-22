import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../app_start_service/notifiers/app_preferences.dart';

class BottomBarPageView extends ConsumerWidget implements PreferredSizeWidget {
  const BottomBarPageView({required this.bottomMenu, super.key});

  final CLContextMenu bottomMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor =
        ref.watch(appPreferenceProvider.select((e) => e.iconColor));
    final iconSize = ref.watch(appPreferenceProvider.select((e) => e.iconSize));

    return Row(
      children: bottomMenu.actions
          .map(
            (e) => Expanded(
              child: ShadButton.ghost(
                onPressed: e.onTap,
                child: Icon(
                  e.icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
