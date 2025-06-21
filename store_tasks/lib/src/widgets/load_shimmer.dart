import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';

class LoadShimmer extends StatelessWidget {
  const LoadShimmer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[200]!,
      child: ColoredBox(
        color: ShadTheme.of(context).colorScheme.muted,
        child: child,
      ),
    );
  }
}
