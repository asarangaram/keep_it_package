import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnShareButton extends StatelessWidget {
  const OnShareButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.share2, color: iconColor, size: 20),
    );
  }
}
