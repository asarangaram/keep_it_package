import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../../internal/entity_grid/builders/get_selection_mode.dart';
import '../../../basic_page_service/widgets/page_manager.dart';
import '../../providers/active_collection.dart';
import '../popover_menu.dart';

class KeepItTopBar extends ConsumerWidget {
  const KeepItTopBar({
    required this.parentIdentifier,
    required this.clmedias,
    super.key,
  });
  final String parentIdentifier;
  final CLMedias clmedias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: collectionId.toString(),
    );
    return GetCollection(
      id: collectionId,
      loadingBuilder: () => CLLoader.hide(
        debugMessage: 'GetCollection',
      ),
      errorBuilder: (p0, p1) => const SizedBox.shrink(),
      builder: (collection) {
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
                if (collectionId != null)
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
                          ref.read(activeCollectionProvider.notifier).state =
                              null;
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
                        collection?.label.capitalizeFirstLetter() ?? 'Keep It',
                        style: Theme.of(context).textTheme.headlineLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                /* SelectionControlIcon(
                  viewIdentifier: viewIdentifier,
                ), */
                if (clmedias.isNotEmpty)
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
            if (clmedias.isNotEmpty)
              TextFilterBox(
                parentIdentifier: parentIdentifier,
              ),
          ],
        );
      },
    );
  }
}
