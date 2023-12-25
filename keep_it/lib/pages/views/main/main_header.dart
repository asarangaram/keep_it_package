import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    super.key,
    required this.quickMenuScopeKey,
    this.actionsBuilders,
    this.mainActionItems,
    this.title,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<
      Widget Function(BuildContext context,
          GlobalKey<State<StatefulWidget>> quickMenuScopeKey)>? actionsBuilders;
  final List<List<CLMenuItem>>? mainActionItems;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (title != null)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CLText.veryLarge(
                  title!,
                ),
              ),
            ),
          if (actionsBuilders != null && actionsBuilders!.isNotEmpty)
            ...actionsBuilders!.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: e(context, quickMenuScopeKey),
                )),
          if (mainActionItems != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CLQuickMenuAnchor(
                parentKey: quickMenuScopeKey,
                menuBuilder: (context, boxconstraints,
                    {required Function() onDone}) {
                  return CLButtonsGrid(
                    scaleType: CLScaleType.veryLarge,
                    size: const Size(kMinInteractiveDimension * 1.5,
                        kMinInteractiveDimension * 1.5),
                    children2D: insertOnDone(context, mainActionItems!, onDone),
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

  static List<List<CLMenuItem>> insertOnDone(
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