import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CLLoadingView extends StatelessWidget {
  const CLLoadingView({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Center(
        child: ScalingText(
          message ?? 'Loading ...',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
