import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_header.dart';

class KeepItMainView extends ConsumerStatefulWidget {
  const KeepItMainView({
    required this.pageBuilder,
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
              
              /* mainActionItems: const [
                [
                  CLMenuItem(
                    title: 'Paste',
                    icon: Icons.content_paste_go_outlined,
                  ),
                  CLMenuItem(
                    title: 'Settings',
                    icon: Icons.settings,
                    /*Icons.settings_applications_sharp,*/
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
