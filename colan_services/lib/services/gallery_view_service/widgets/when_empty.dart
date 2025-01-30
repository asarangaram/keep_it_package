import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../providers/active_collection.dart';

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final onRecover = collectionId == null
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
      errorMessage: 'Empty',
      errorDetails: 'Go Online to view collections '
          'in the server',
      onRecover: onRecover,
    );
  }
}
