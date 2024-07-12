import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_button.dart';
import '../../models/cl_menu_item.dart';

class Menu extends ConsumerWidget {
  const Menu({
    required this.menuItems,
    super.key,
  });
  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(128 + 64, 128 + 64, 128 + 64, 128 + 64),
            blurRadius: 20, // soften the shadow
            offset: Offset(
              10, // Move to right 10  horizontally
              5, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 18, top: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: menuItems
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: CLButtonIconLabelled.small(
                      e.icon,
                      e.title,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      onTap: () async {
                        await e.onTap?.call();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
