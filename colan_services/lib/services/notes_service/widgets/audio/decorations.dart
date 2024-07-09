import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class RecordedAudioDecoration extends StatelessWidget {
  const RecordedAudioDecoration({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = const DefaultNotesInputTheme().copyWith(
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
        color: theme.backgroundColor,
      ),
      margin: theme.margin,
      padding: theme.padding,
      child: child,
    );
  }
}
