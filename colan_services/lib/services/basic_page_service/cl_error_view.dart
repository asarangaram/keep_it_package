import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({
    required this.errorMessage,
    super.key,
    this.errorDetails,
    this.onRecover,
  });

  final String errorMessage;
  final String? errorDetails;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      menuItems: [
        if (onRecover != null) onRecover!,
      ],
      message: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLIcon.veryLarge(
              clIcons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            CLText.large(trim(errorMessage)),
            /* if (!isAllAvailable)  */ ...[
              const SizedBox(
                height: 32,
              ),
              if (errorDetails != null)
                CLText.standard(
                  errorDetails!,
                  color: Colors.grey,
                ),
            ],
          ],
        ),
      ),
    );
  }

  String trim(String msg) {
    final parts = msg.split(':');
    return parts.last;
  }
}

class CLErrorPage extends StatelessWidget {
  const CLErrorPage({
    required this.errorMessage,
    super.key,
    this.errorDetails,
    this.onRecover,
  });

  final String errorMessage;
  final String? errorDetails;
  final CLMenuItem? onRecover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CLErrorView(
        errorMessage: errorMessage,
        errorDetails: errorDetails,
        onRecover: onRecover,
      ),
    );
  }
}
