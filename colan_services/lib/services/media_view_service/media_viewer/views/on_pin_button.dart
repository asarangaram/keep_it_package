import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnPinButton extends StatelessWidget {
  const OnPinButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.pin, color: iconColor, size: 20),
    );
  }
}
