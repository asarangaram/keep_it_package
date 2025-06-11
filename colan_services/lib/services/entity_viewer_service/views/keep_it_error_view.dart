import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/cl_error_view.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'top_bar.dart';

class KeepItErrorView extends ConsumerWidget {
  const KeepItErrorView(
      {required this.e,
      required this.st,
      required this.parentIdentifier,
      super.key,
      this.onRecover});
  final Object e;
  final StackTrace st;
  final CLMenuItem? onRecover;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItem = onRecover == null
        ? null
        : CLMenuItem(
            title: 'Reset',
            icon: clIcons.navigateHome,
            onTap: () async {
              if (PageManager.of(context).canPop()) {
                PageManager.of(context).pop();
              }
              return null;
            },
          );
    return CLScaffold(
      topMenu: TopBar(
          viewIdentifier:
              ViewIdentifier(parentID: parentIdentifier, viewId: 'Error'),
          entityAsync: AsyncError(e, st),
          children: null),
      banners: const [],
      bottomMenu: null,
      body: CLErrorView(
        errorMessage: e.toString(),
        errorDetails: st.toString(),
        onRecover: menuItem,
      ),
    );
  }
}
