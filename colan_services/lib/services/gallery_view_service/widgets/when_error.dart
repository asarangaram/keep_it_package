import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhenError extends ConsumerWidget {
  const WhenError({
    required this.errorMessage,
    super.key,
    this.errorDetails,
    this.onRecover,
  });

  final String errorMessage;
  final String? errorDetails;
  final CLMenuItem? onRecover;
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
    return CLErrorView(
      errorMessage: errorMessage,
      errorDetails: errorDetails,
      onRecover: menuItem,
    );
  }
}
