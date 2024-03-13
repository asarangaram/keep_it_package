import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    required this.quickMenuScopeKey,
    super.key,
    this.actionsBuilders,
    this.mainActionItems,
    this.title,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<
      Widget Function(
        BuildContext context,
        GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
      )>? actionsBuilders;
  final List<List<CLMenuItem>>? mainActionItems;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (context.canPop())
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CLButtonIcon.small(
                Icons.arrow_back,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
          Flexible(
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
                  ...actionsBuilders!.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: e(context, quickMenuScopeKey),
                    ),
                  ),
                if (mainActionItems != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CLQuickMenuAnchor(
                      parentKey: quickMenuScopeKey,
                      menuBuilder: (
                        context,
                        boxconstraints, {
                        required void Function() onDone,
                      }) {
                        return CLButtonsGrid(
                          scaleType: CLScaleType.veryLarge,
                          size: const Size(
                            kMinInteractiveDimension * 1.5,
                            kMinInteractiveDimension * 1.5,
                          ),
                          children2D: mainActionItems!.insertOnDone(onDone),
                        );
                      },
                      child: const CLIcon.small(
                        Icons.more_vert,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
