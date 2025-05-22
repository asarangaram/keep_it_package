import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart' show StoreExtensionOnString;

import '../../../models/platform_support.dart';
import '../../app_start_service/notifiers/app_preferences.dart';
import '../../app_start_service/views/on_dark_mode.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../gallery_view_service/widgets/popover_menu.dart';
import '../../gallery_view_service/widgets/refresh_button.dart';

class TopBarGridView extends ConsumerWidget implements PreferredSizeWidget {
  const TopBarGridView({
    required this.viewIdentifier,
    required this.storeIdentity,
    required this.parent,
    required this.children,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  final ViewerEntityMixin? parent;
  final List<ViewerEntityMixin> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor =
        ref.watch(appPreferenceProvider.select((e) => e.iconColor));
    final iconSize = ref.watch(appPreferenceProvider.select((e) => e.iconSize));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: Text(
            parent?.label!.capitalizeFirstLetter() ?? 'Keep It',
            style: ShadTheme.of(context).textTheme.h1,
          ),
          actions: [
            if (!ColanPlatformSupport.isMobilePlatform) const RefreshButton(),
            const OnDarkMode(),
            if (children.isNotEmpty)
              PopOverMenu(viewIdentifier: viewIdentifier)
            else
              ShadButton.ghost(
                onPressed: () => PageManager.of(context).openSettings(),
                child: Icon(
                  clIcons.settings,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
          ],
        ),
        if (children.isNotEmpty)
          TextFilterBox(parentIdentifier: viewIdentifier.parentID),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
