import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    super.key,
    required this.quickMenuScopeKey,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

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
                return AppTheme(
                  child: CLQuickMenuGrid(
                    menuItems: [
                      for (var i = 0; i < 1; i++) ...[
                        CLMenuItem(
                          'Paste',
                          Icons.content_paste,
                          onTap: () {
                            debugPrint("paste");
                            onDone();
                          },
                        ),
                        CLMenuItem(
                          'Settings',
                          Icons.settings,
                          onTap: () {
                            debugPrint("settings");
                            onDone();
                          },
                        ),
                      ]
                    ],
                  ),
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
