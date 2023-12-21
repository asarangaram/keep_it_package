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
  final List<List<CLMenuItem>> menuItems;

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
                "Keep It",
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
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(200),
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  menuItems: insertOnDone(context, menuItems, onDone),
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

  List<List<CLMenuItem>> insertOnDone(
      BuildContext context, List<List<CLMenuItem>> items, onDone) {
    return items.map((list) {
      return list
          .map((e) => CLMenuItem(e.title, e.icon, onTap: () {
                if (e.onTap != null) {
                  e.onTap!.call();
                } else {
                  CLButtonsGrid.showSnackBarAboveDialog(context, e.title);
                }
                onDone();
              }))
          .toList();
    }).toList();
  }
}
/*
[
                    for (var i = 0; i < 1; i++) ...[
                      
                    ]
                  ]
*/