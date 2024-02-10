import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CLText.large(
          'Nothing to see here',
        ),
      ),
    );
  }
}
