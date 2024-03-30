import 'package:flutter/material.dart';

class CLRefreshIndicator extends StatelessWidget {
  const CLRefreshIndicator({
    required this.child,
    required Key key,
    this.onRefresh,
  })  : refreshKey = key,
        super(key: null);
  final Future<void> Function()? onRefresh;
  final Widget child;
  final Key refreshKey;
  @override
  Widget build(BuildContext context) {
    if (onRefresh == null) {
      return child;
    }
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: onRefresh!,
      child: child,
    );
  }
}
