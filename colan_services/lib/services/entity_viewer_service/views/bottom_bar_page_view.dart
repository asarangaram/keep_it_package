import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/entity_actions.dart';

class BottomBarPageView extends ConsumerWidget implements PreferredSizeWidget {
  const BottomBarPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetCurrentEntity(
      builder: (entity) {
        final bottomMenu =
            EntityActions.ofEntity(context, ref, entity as StoreEntity);
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
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
