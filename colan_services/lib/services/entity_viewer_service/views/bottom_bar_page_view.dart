import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BottomBarPageView extends ConsumerWidget implements PreferredSizeWidget {
  const BottomBarPageView({required this.bottomMenu, super.key});
  final CLContextMenu bottomMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: bottomMenu.actions
          .map(
            (e) => Expanded(
              child: ShadButton.ghost(
                onPressed: e.onTap,
                child: e.icon.iconFormatted(),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
