import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
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
    final menuItems = [
      CLMenuItem(
        title: 'Disconnect',
        icon: clIcons.noNetwork,
        onTap: () async {
          return null;
        },
      )
    ];
    return CLScaffold(
      topMenu: TopBar(
          viewIdentifier:
              ViewIdentifier(parentID: parentIdentifier, viewId: 'Error'),
          entityAsync: AsyncError(e, st),
          children: null),
      banners: const [],
      bottomMenu: null,
      body: GetStoreStatus(
        builder: ({required isConnected, required storeAsync}) {
          if (!isConnected) {
            return CLErrorView(
              errorMessage: 'Connection error',
              errorDetails: 'You are not connected to any home network',
              menuItems: menuItems,
            );
          }
          return storeAsync.when(
              data: (store) {
                if (!store.store.isAlive) {
                  return CLErrorView(
                    errorMessage: 'Store found but is not accessible',
                    errorDetails:
                        "Store is not responding, couldn't determine the id",
                    menuItems: menuItems,
                  );
                } else {
                  return CLErrorView(
                    errorMessage: e.toString(),
                    errorDetails: st.toString(),
                    menuItems: menuItems,
                  );
                }
              },
              error: (storeError, storeSt) {
                return CLErrorView(
                  errorMessage: 'Store is not accessible',
                  errorDetails:
                      "$e\n${st.toString().split("\n").take(2).join("\n")}",
                  menuItems: menuItems,
                );
              },
              loading: () => CLLoader.widget(debugMessage: null));
        },
      ),
    );
  }
}
