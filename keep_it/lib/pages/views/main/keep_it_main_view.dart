import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_header.dart';

class KeepItMainView extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context,
      GlobalKey<State<StatefulWidget>> quickMenuScopeKey) pageBuilder;
  final List<List<CLMenuItem>> menuItems;

  const KeepItMainView({
    super.key,
    required this.pageBuilder,
    required this.menuItems,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => KeepItMainViewState();
}

class KeepItMainViewState extends ConsumerState<KeepItMainView> {
  final GlobalKey quickMenuScopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      useSafeArea: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CLQuickMenuScope(
          key: quickMenuScopeKey,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MainHeader(
                  quickMenuScopeKey: quickMenuScopeKey,
                  menuItems: [
                    ...widget.menuItems,
                    [
                      CLMenuItem(
                        'Clipboard',
                        Icons.content_paste,
                      ),
                      CLMenuItem(
                        'Settings',
                        Icons.settings,
                      ),
                    ],
                  ],
                ),
                Expanded(child: widget.pageBuilder(context, quickMenuScopeKey))
              ]),
        ),
      ),
    );
  }
}
