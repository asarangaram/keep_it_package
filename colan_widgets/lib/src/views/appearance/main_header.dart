import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_buttons_grid.dart';
import '../../basics/cl_icon.dart';
import '../../basics/cl_text.dart';
import '../../extensions/ext_cl_menu_item.dart';
import '../../models/cl_menu_item.dart';
import '../../models/cl_scale_type.dart';
import '../../theme/models/cl_icons.dart';
import '../quick_menu/cl_quickmenu.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    required this.quickMenuScopeKey,
    required this.backButton,
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
  final Widget? backButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (backButton != null) backButton!,
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
                      child: CLIcon.small(
                        clIcons.extraMenu,
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
