import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnCropButton extends StatelessWidget {
  const OnCropButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.crop, color: iconColor, size: 20),
    );
  }
}
