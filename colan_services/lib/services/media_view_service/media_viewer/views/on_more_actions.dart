import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnMoreActions extends StatelessWidget {
  const OnMoreActions({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.circleEllipsis, color: iconColor, size: 20),
      onPressed: () {},
    );
  }
}
