import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_collection.dart';

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    final onRecover = parentId == null
        ? null
        : CLMenuItem(
            title: 'Reset',
            icon: clIcons.navigateHome,
            onTap: () async {
              ref.read(activeCollectionProvider.notifier).state = null;
              return true;
            },
          );

    return CLErrorView(
      errorMessage: 'Nothing to show',
      errorDetails:
          'Import Photos and Videos from the Gallery or using Camera. '
          'Connect to server to view your home collections '
          "using 'Cloud on LAN' service.",
      onRecover: onRecover,
    );
  }
}
