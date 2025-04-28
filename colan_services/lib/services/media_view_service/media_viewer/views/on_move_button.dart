import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnMoveButton extends StatelessWidget {
  const OnMoveButton({required this.iconColor, super.key});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.folderInput, color: iconColor, size: 20),
    );
  }
}
