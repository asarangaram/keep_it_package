import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnMoveButton extends StatelessWidget {
  const OnMoveButton({super.key, required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      child: Icon(LucideIcons.folderInput, color: iconColor, size: 20),
    );
  }
}
