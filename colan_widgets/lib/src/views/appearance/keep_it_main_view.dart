import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/ext_string.dart';
import '../quick_menu/cl_quickmenu.dart';
import 'main_header.dart';

class KeepItMainView extends ConsumerStatefulWidget {
  const KeepItMainView({
    required this.pageBuilder,
    required this.backButton,
    super.key,
    this.actionsBuilder,
    this.title,
  });
  final Widget Function(
    BuildContext context,
    GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  ) pageBuilder;
  final List<
      Widget Function(
        BuildContext context,
        GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
      )>? actionsBuilder;

  final String? title;
  final Widget? backButton;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => KeepItMainViewState();
}

class KeepItMainViewState extends ConsumerState<KeepItMainView> {
  final GlobalKey quickMenuScopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: CLQuickMenuScope(
        key: quickMenuScopeKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MainHeader(
              actionsBuilders: widget.actionsBuilder,
              quickMenuScopeKey: quickMenuScopeKey,
              title: widget.title?.uptoLength(15),
              backButton: widget.backButton,

              /* mainActionItems: const [
                [
                  CLMenuItem(
                    title: 'Paste',
                    icon: clIcons.content_paste_go_outlined,
                  ),
                  CLMenuItem(
                    title: 'Settings',
                    icon: clIcons.settings,
                    /*clIcons.settings_applications_sharp,*/
                  ),
                ],
              ], */
            ),
            Expanded(child: widget.pageBuilder(context, quickMenuScopeKey)),
          ],
        ),
      ),
    );
  }
}
