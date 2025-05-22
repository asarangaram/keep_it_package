import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart' show StoreExtensionOnString;

import '../../../models/platform_support.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'popover_menu.dart';
import 'refresh_button.dart';

class TopBarGridView extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
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
            if (children.isNotEmpty)
              PopOverMenu(viewIdentifier: viewIdentifier)
            else
              ShadButton.ghost(
                onPressed: () => PageManager.of(context).openSettings(),
                child: const Icon(LucideIcons.settings),
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
