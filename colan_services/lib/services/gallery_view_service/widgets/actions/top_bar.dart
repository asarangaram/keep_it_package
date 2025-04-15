import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../basic_page_service/widgets/page_manager.dart';
import '../../providers/active_collection.dart';
import '../popover_menu.dart';

class KeepItTopBar extends ConsumerWidget {
  const KeepItTopBar({
    required this.parentIdentifier,
    required this.entities,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentCollection = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentCollection?.id.toString() ?? 'All',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!ColanPlatformSupport.isMobilePlatform)
          const SizedBox(
            height: 8,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (parentCollection != null)
              GetSelectionMode(
                viewIdentifier: viewIdentifier,
                builder: ({
                  required onUpdateSelectionmode,
                  required tabIdentifier,
                  required selectionMode,
                }) {
                  return CLButtonIcon.small(
                    clIcons.pagePop,
                    onTap: () {
                      onUpdateSelectionmode(enable: false);
                      ref.read(activeCollectionProvider.notifier).state = null;
                    },
                  );
                },
              ),
            Flexible(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    parentCollection?.data.label!.capitalizeFirstLetter() ??
                        'Keep It',
                    style: Theme.of(context).textTheme.headlineLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            /* SelectionControlIcon(
                  viewIdentifier: viewIdentifier,
                ), */
            if (!ColanPlatformSupport.isMobilePlatform)
              ShadButton.ghost(
                onPressed: ref.read(reloadProvider.notifier).reload,
                child: const Icon(LucideIcons.refreshCcw, size: 25),
              ),
            if (entities.isNotEmpty)
              PopOverMenu(
                viewIdentifier: viewIdentifier,
              )
            else
              ShadButton.ghost(
                onPressed: () => PageManager.of(context).openSettings(),
                child: const Icon(LucideIcons.settings, size: 25),
              ),
          ],
        ),
        if (entities.isNotEmpty)
          TextFilterBox(
            parentIdentifier: parentIdentifier,
          ),
      ],
    );
  }
}
