import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

class BannerView extends StatelessWidget {
  const BannerView({
    required this.staleMediaCount,
    required this.onTap,
    super.key,
  });
  final int staleMediaCount;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          color: ShadTheme.of(context).colorScheme.mutedForeground,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          width: double.infinity,

          // height: kMinInteractiveDimension,
          child: Center(
            child: Text(
              'You have $staleMediaCount unclassified media. Tap here to show',
              style: ShadTheme.of(context).textTheme.small.copyWith(
                    color: ShadTheme.of(context).colorScheme.muted,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
