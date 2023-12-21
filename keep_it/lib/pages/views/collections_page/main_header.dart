import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    super.key,
    required this.quickMenuScopeKey,
    required this.menuItems,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(
            child: Center(
              child: CLText.veryLarge(
                "Collections",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CLQuickMenuAnchor(
              parentKey: quickMenuScopeKey,
              menuBuilder: (context, boxconstraints,
                  {required Function() onDone}) {
                return CLQuickMenuGrid(
                  menuItems: menuItems.map((e) {
                    return CLMenuItem(e.title, e.icon, onTap: () {
                      e.onTap?.call();
                      onDone();
                    });
                  }).toList(),
                );
              },
              child: const CLIcon.small(
                Icons.more_vert,
              ),
            ),
          )
        ],
      ),
    );
  }
}
/*
[
                    for (var i = 0; i < 1; i++) ...[
                      
                    ]
                  ]
*/