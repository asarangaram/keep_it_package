import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'collections_page/main_header.dart';

abstract class KeepItPage extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  const KeepItPage({
    super.key,
    required this.quickMenuScopeKey,
  });
}

class KeepItMainView extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context,
      GlobalKey<State<StatefulWidget>> quickMenuScopeKey) pageBuilder;
  final List<CLMenuItem> menuItems;

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
                    CLMenuItem(
                      'Paste',
                      Icons.content_paste,
                      onTap: () {
                        debugPrint("paste");
                      },
                    ),
                    CLMenuItem(
                      'Settings',
                      Icons.settings,
                      onTap: () {
                        debugPrint("settings");
                      },
                    ),
                  ],
                ),
                Expanded(child: widget.pageBuilder(context, quickMenuScopeKey))
              ]),
        ),
      ),
    );
  }
}
