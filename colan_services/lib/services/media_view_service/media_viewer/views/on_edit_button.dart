import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnEditButton extends StatelessWidget {
  const OnEditButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.pencil, color: iconColor, size: 20),
    );
  }
}
