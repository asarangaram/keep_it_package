import 'package:flutter/material.dart';

import '../../basics/cl_icon.dart';
import '../../basics/cl_text.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({
    required this.errorMessage,
    super.key,
    this.errorDetails,
  });

  final String errorMessage;
  final String? errorDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CLIcon.veryLarge(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                CLText.veryLarge(
                  errorMessage,
                  color: Theme.of(context).colorScheme.error,
                ),
                if (errorDetails != null)
                  CLText.small(
                    errorDetails!,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
