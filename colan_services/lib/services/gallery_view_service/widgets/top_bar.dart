import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/widgets/cl_banner.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../models/platform_support.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'popover_menu.dart';

class KeepItTopBar extends CLBanner {
  const KeepItTopBar({
    required this.viewIdentifier,
    required this.entities,
    required this.title,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final List<StoreEntity> entities;
  final String title;
  @override
  String get widgetLabel => 'top bar';
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref, {
    Color? backgroundColor,
    Color? foregroundColor,
    String msg = '',
    void Function()? onTap,
  }) {
    return Padding(
      padding: ColanPlatformSupport.isMobilePlatform
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetSelectionMode(
                viewIdentifier: viewIdentifier,
                builder: ({
                  required onUpdateSelectionmode,
                  required viewIdentifier,
                  required selectionMode,
                }) {
                  return CLButtonIcon.small(
                    clIcons.pagePop,
                    onTap: () {
                      onUpdateSelectionmode(enable: false);
                      if (PageManager.of(context).canPop()) {
                        PageManager.of(context).pop();
                      }
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
                      title,
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
                PopOverMenu(viewIdentifier: viewIdentifier)
              else
                ShadButton.ghost(
                  onPressed: () => PageManager.of(context).openSettings(),
                  child: const Icon(LucideIcons.settings, size: 25),
                ),
            ],
          ), */
          if (entities.isNotEmpty)
            TextFilterBox(parentIdentifier: viewIdentifier.parentID),
        ],
      ),
    );
  }
}
