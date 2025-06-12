import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basic_page_service/widgets/cl_error_view.dart';
import 'top_bar.dart';

class KeepItErrorView extends ConsumerWidget {
  const KeepItErrorView(
      {required this.e, required this.st, super.key, this.onRecover});
  final Object e;
  final StackTrace st;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = <CLMenuItem>[];
    return CLScaffold(
      topMenu: TopBar(entityAsync: AsyncError(e, st), children: null),
      banners: const [],
      bottomMenu: null,
      body: GetStoreStatus(
        builder: (
            {required activeURL,
            required bool isConnected,
            required storeAsync}) {
          final storeError = storeAsync.when(
              data: (store) {
                if (!store.store.isAlive) {
                  return CLErrorView(
                    errorMessage: 'Connection Error',
                    errorDetails: 'Lost Connection to ${store.store.identity}',
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

          return activeURL.when(
              data: (activeURLValue) {
                return switch (activeURLValue.scheme) {
                  'local' => CLErrorView(
                      errorMessage: e.toString(),
                      errorDetails: st.toString(),
                      menuItems: menuItems,
                    ),
                  (final String scheme)
                      when ['http', 'https'].contains(scheme) =>
                    isConnected
                        ? storeError
                        : CLErrorView(
                            errorMessage: 'Connection error',
                            errorDetails:
                                'You are not connected to any home network',
                            menuItems: menuItems,
                          ),
                  _ => throw Exception('Unsupported URL') // should never occur
                };
              },
              error: (activeURLErr, activeURLST) {
                return CLErrorView(
                  errorMessage: activeURLErr.toString(),
                  errorDetails: activeURLST.toString(),
                  menuItems: menuItems,
                );
              },
              loading: () => CLLoader.widget(debugMessage: null));
        },
      ),
    );
  }
}
