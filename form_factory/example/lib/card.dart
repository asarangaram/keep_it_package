import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TheCard extends StatelessWidget {
  const TheCard({
    super.key,
    required this.title,
    required this.child,
    required this.footerText,
  });
  final String title;
  final Widget child;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      title: Text(title, style: theme.textTheme.lead),
      footer: Text(footerText, style: ShadTheme.of(context).textTheme.muted),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: child,
      ),
    );
  }
}
