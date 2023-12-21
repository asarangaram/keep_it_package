import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({Key? key, required this.errorMessage, this.errorDetails})
      : super(key: key);

  final String errorMessage;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CLText.veryLarge(errorMessage,
                  color: Theme.of(context).colorScheme.error),
              if (errorDetails != null)
                CLText.small(errorDetails!,
                    color: Theme.of(context).colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }
}
