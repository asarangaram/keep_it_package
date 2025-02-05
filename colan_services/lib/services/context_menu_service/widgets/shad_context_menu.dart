import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/context_menu_items.dart';

class ShadContextMenu extends StatelessWidget {
  const ShadContextMenu({
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
              child: Center(
                child: Center(child: Icon(item.icon)),
              ),
            ),
            enabled: item.onTap != null,
            onPressed: item.onTap,
            textStyle: textStyle,
            child: Text(item.title),
          ),
        if (contextMenu!.onlineActions.any((e) => e.onTap != null)) ...[
          const Divider(height: 8),
          for (final item in contextMenu!.onlineActions)
            if (item.onTap != null)
              ShadContextMenuItem(
                leading: SizedBox.square(
                  dimension: 16,
                  child: Center(
                    child: Center(child: Icon(item.icon)),
                  ),
                ),
                textStyle: textStyle,
                enabled: item.onTap != null,
                onPressed: item.onTap,
                child: Text(item.title),
              ),
        ],
        for (final item in contextMenu!.destructiveActions)
          if (item.onTap != null)
            ShadContextMenuItem(
              leading: SizedBox.square(
                dimension: 16,
                child: Center(
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: ShadTheme.of(context).colorScheme.destructive,
                    ),
                  ),
                ),
              ),
              textStyle: textStyle.copyWith(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
              enabled: item.onTap != null,
              onPressed: item.onTap,
              child: Text(item.title),
            ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
