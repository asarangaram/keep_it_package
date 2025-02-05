import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/context_menu_items.dart';

class CLBasicContextMenu extends StatelessWidget {
  const CLBasicContextMenu({
    required this.child,
    super.key,
    this.onTap,
    this.contextMenu,
  });

  final Widget child;
  final Future<bool?> Function()? onTap;
  final CLContextMenu? contextMenu;

  @override
  Widget build(BuildContext context) {
    final textStyle = ShadTheme.of(context).textTheme.small;
    if (contextMenu == null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return ShadContextMenuRegion(
      constraints: const BoxConstraints(minWidth: 100),
      items: [
        for (final item in contextMenu!.basicActions)
          ShadContextMenuItem(
            leading: SizedBox.square(
              dimension: 16,
              child: Center(child: Icon(item.icon)),
            ),
            enabled: item.onTap != null,
            onPressed: item.onTap,
            textStyle: textStyle.copyWith(
              color: item.isDestructive
                  ? ShadTheme.of(context).colorScheme.destructive
                  : null,
            ),
            child: Text(item.title),
          ),
        if (contextMenu!.onlineActions.any((e) => e.onTap != null)) ...[
          const Divider(height: 8),
          for (final item in contextMenu!.onlineActions)
            if (item.onTap != null)
              ShadContextMenuItem(
                leading: SizedBox.square(
                  dimension: 16,
                  child: Center(child: Icon(item.icon)),
                ),
                textStyle: textStyle.copyWith(
                  color: item.isDestructive
                      ? ShadTheme.of(context).colorScheme.destructive
                      : null,
                ),
                enabled: item.onTap != null,
                onPressed: item.onTap,
                child: Text(item.title),
              ),
        ],
        ShadContextMenuItem(
          leading: SizedBox.square(
            dimension: 16,
            child: Center(child: Icon(clIcons.recycleBin)),
          ),
          trailing: const Icon(LucideIcons.chevronRight),
          items: [
            for (final item in contextMenu!.destructiveActions)
              if (item.onTap != null)
                ShadContextMenuItem(
                  leading: SizedBox.square(
                    dimension: 16,
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: ShadTheme.of(context).colorScheme.destructive,
                      ),
                    ),
                  ),
                  textStyle: textStyle.copyWith(
                    color: item.isDestructive
                        ? ShadTheme.of(context).colorScheme.destructive
                        : null,
                  ),
                  enabled: item.onTap != null,
                  onPressed: item.onTap,
                  child: Text(item.title),
                ),
          ],
          child: const Text('Remove'),
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
