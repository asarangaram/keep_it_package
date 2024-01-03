import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'views/main/keep_it_main_view.dart';

class ClusterPage extends ConsumerWidget {
  const ClusterPage({super.key, required this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      useSafeArea: false,
      child: KeepItMainView(
        onPop: context.canPop()
            ? () {
                context.pop();
              }
            : null,
        pageBuilder: (context, quickMenuScopeKey) {
          return Center(
            child: Text(collectionId.toString()),
          );
        },
      ),
    );
  }
}
