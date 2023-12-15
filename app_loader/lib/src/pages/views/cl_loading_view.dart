import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CLLoadingView extends StatelessWidget {
  const CLLoadingView({
    Key? key,
    this.message,
  }) : super(key: key);

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScalingText(
            message ?? 'Loading ...',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
}
/*
return const CupertinoActivityIndicator(
        radius: 20.0, color: CupertinoColors.activeBlue);
*/