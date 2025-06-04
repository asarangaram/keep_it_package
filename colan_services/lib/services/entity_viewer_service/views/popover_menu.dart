import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../basic_page_service/widgets/page_manager.dart';

class PopOverMenu extends ConsumerStatefulWidget {
  const PopOverMenu({required this.viewIdentifier, super.key});
  final ViewIdentifier viewIdentifier;

  @override
  ConsumerState<PopOverMenu> createState() => _PopoverPageState();
}

class _PopoverPageState extends ConsumerState<PopOverMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      popover: (_) => SizedBox(
        width: 288,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShadButton.ghost(
                  onPressed: popoverController.hide,
                  child: const Icon(LucideIcons.check, size: 25),
                ),
                ShadButton.ghost(
                  onPressed: () => PageManager.of(context)
                      .openSettings()
                      .then((val) => popoverController.hide()),
                  child: const Icon(LucideIcons.settings, size: 25),
                ),
              ],
            ),
            SingleChildScrollView(
              child: ViewModifierSettings(
                viewIdentifier: widget.viewIdentifier,
              ),
            ),
          ],
        ),
      ),
      child: GetViewModifiers(
        viewIdentifier: widget.viewIdentifier,
        builder: (items) {
          return ShadButton.ghost(
            padding: const EdgeInsets.only(right: 8),
            onPressed: popoverController.toggle,
            child: clIcons.extraMenu.iconFormatted(
              color: items.any((e) => e.isActive)
                  ? ShadTheme.of(context).colorScheme.destructive
                  : null,
            ),
          );
        },
      ),
    );
  }
}
