import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  static Widget? cache;
  @override
  Widget build(BuildContext context) {
    return cache ??= const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CLText.large(
          'Nothing to see here',
        ),
      ),
    );
  }
}
