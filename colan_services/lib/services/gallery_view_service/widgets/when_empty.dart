import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhenEmpty extends ConsumerWidget {
  const WhenEmpty({
    super.key,
    this.onReset,
  });
  final Future<bool?> Function()? onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItem = onReset == null
        ? null
        : CLMenuItem(
            title: 'Reset',
            icon: clIcons.navigateHome,
            onTap: onReset ??
                () async {
                  if (PageManager.of(context).canPop()) {
                    PageManager.of(context).pop();
                  }
                  return true;
                },
          );

    return CLErrorView(
      errorMessage: 'Nothing to show',
      errorDetails:
          'Import Photos and Videos from the Gallery or using Camera. '
          'Connect to server to view your home collections '
          "using 'Cloud on LAN' service.",
      onRecover: menuItem,
    );
  }
}
