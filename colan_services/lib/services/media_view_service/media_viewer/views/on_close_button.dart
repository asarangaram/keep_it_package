import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnCloseButton extends StatelessWidget {
  const OnCloseButton({required this.iconColor, super.key});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: () {
        PageManager.of(context).pop();
      },
      child: Icon(Icons.arrow_back_ios, color: iconColor),
    );
  }
}
